import gleam/map.{Map}
import gleam/pair
import gleam_zlists.{ZList} as zlist
import gleam/dynamic.{Decoder}
import gleam/json.{Json}
import gleam_synapses/model/encoding/serialization.{
  Attribute, AttributeSerialized, DiscreteAttribute, DiscreteAttributeSerialized,
}

pub fn updated(
  discrete_attribute: Attribute,
  datapoint: Map(String, String),
) -> Attribute {
  assert DiscreteAttribute(key, values) = discrete_attribute
  assert Ok(v) = map.get(datapoint, key)
  let updated_values = case zlist.has_member(values, v) {
    True -> values
    False -> zlist.cons(values, v)
  }
  DiscreteAttribute(key, values: updated_values)
}

pub fn encode(discrete_attribute: Attribute, value: String) -> ZList(Float) {
  assert DiscreteAttribute(_, values) = discrete_attribute
  values
  |> zlist.map(fn(x) {
    case x == value {
      True -> 1.0
      False -> 0.0
    }
  })
}

pub fn decode(
  discrete_attribute: Attribute,
  encoded_values: ZList(Float),
) -> String {
  assert DiscreteAttribute(_, values) = discrete_attribute
  assert Ok(#(hd, tl)) =
    values
    |> zlist.zip(encoded_values)
    |> zlist.uncons
  zlist.reduce(
    tl,
    hd,
    fn(x, acc) {
      let #(_, x_float_val) = x
      let #(_, acc_float_val) = acc
      case x_float_val >. acc_float_val {
        True -> x
        False -> acc
      }
    },
  )
  |> pair.first
}

pub fn serialized(discrete_attribute: Attribute) -> AttributeSerialized {
  assert DiscreteAttribute(key, values) = discrete_attribute
  DiscreteAttributeSerialized(key, zlist.to_list(values))
}

pub fn deserialized(
  discrete_attribute_serialized: AttributeSerialized,
) -> Attribute {
  assert DiscreteAttributeSerialized(key, values) =
    discrete_attribute_serialized
  DiscreteAttribute(key, zlist.of_list(values))
}

pub fn json_encoded(discrete_attribute_serialized: AttributeSerialized) -> Json {
  assert DiscreteAttributeSerialized(key, values) =
    discrete_attribute_serialized
  json.object([
    #("key", json.string(key)),
    #("values", json.array(values, json.string)),
  ])
}

pub fn json_decoder() -> Decoder(AttributeSerialized) {
  dynamic.decode2(
    DiscreteAttributeSerialized,
    dynamic.field("key", dynamic.string),
    dynamic.field("values", dynamic.list(dynamic.string)),
  )
}
