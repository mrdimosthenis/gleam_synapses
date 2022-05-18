import gleam/string
import gleam/float
import gleam/int
import gleam/map.{Map}
import gleam/result
import gleam_zlists.{ZList} as zlist
import gleam/dynamic.{Decoder}
import gleam/json.{Json}
import gleam_synapses/model/encoding/serialization.{
  Attribute, AttributeSerialized, ContinuousAttribute, ContinuousAttributeSerialized,
}

pub fn parse(s: String) -> Float {
  let trimmed = string.trim(s)
  case #(float.parse(trimmed), int.parse(trimmed)) {
    #(Ok(x), _) -> x
    #(_, Ok(x)) -> int.to_float(x)
  }
}

pub fn updated(
  continuous_attribute: Attribute,
  datapoint: Map(String, String),
) -> Attribute {
  assert ContinuousAttribute(key, min, max) = continuous_attribute
  assert Ok(v) =
    datapoint
    |> map.get(key)
    |> result.map(parse)
  ContinuousAttribute(key, min: float.min(v, min), max: float.max(v, max))
}

pub fn encode(continuous_attribute: Attribute, value: String) -> ZList(Float) {
  assert ContinuousAttribute(_, min, max) = continuous_attribute
  case min == max {
    True -> 0.5
    False -> {
      let nomin = parse(value) -. min
      let denomin = max -. min
      nomin /. denomin
    }
  }
  |> zlist.singleton
}

pub fn decode(
  continuous_attribute: Attribute,
  encoded_values: ZList(Float),
) -> String {
  assert ContinuousAttribute(_, min, max) = continuous_attribute
  case min == max {
    True -> min
    False -> {
      assert Ok(v) = zlist.head(encoded_values)
      let factor = max -. min
      v *. factor +. min
    }
  }
  |> float.to_string
}

pub fn serialized(continuous_attribute: Attribute) -> AttributeSerialized {
  assert ContinuousAttribute(key, min, max) = continuous_attribute
  ContinuousAttributeSerialized(key, min, max)
}

pub fn deserialized(
  continuous_attribute_serialized: AttributeSerialized,
) -> Attribute {
  assert ContinuousAttributeSerialized(key, min, max) =
    continuous_attribute_serialized
  ContinuousAttribute(key, min, max)
}

pub fn json_encoded(
  continuous_attribute_serialized: AttributeSerialized,
) -> Json {
  assert ContinuousAttributeSerialized(key, min, max) =
    continuous_attribute_serialized
  json.object([
    #("key", json.string(key)),
    #("min", json.float(min)),
    #("max", json.float(max)),
  ])
}

pub fn json_decoder() -> Decoder(AttributeSerialized) {
  dynamic.decode3(
    ContinuousAttributeSerialized,
    dynamic.field("key", dynamic.string),
    dynamic.field("min", dynamic.float),
    dynamic.field("max", dynamic.float),
  )
}
