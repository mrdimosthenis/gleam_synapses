import gleam/dynamic.{Decoder}
import gleam/function
import gleam/json.{Json}
import gleam_synapses/model/encoding/attribute/attribute.{
  Attribute, Continuous, Discrete,
}
import gleam_zlists as zlist

pub fn serialized(attr: Attribute) -> Json {
  case attr {
    Discrete(key, values) -> {
      let field =
        json.object([
          #("key", json.string(key)),
          #(
            "values",
            values
            |> zlist.to_list
            |> json.array(json.string),
          ),
        ])
      json.object([
        #("Case", json.string("SerializableDiscrete")),
        #("Fields", json.array([field], function.identity)),
      ])
    }
    Continuous(key, min, max) -> {
      let field =
        json.object([
          #("key", json.string(key)),
          #("min", json.float(min)),
          #("max", json.float(max)),
        ])
      json.object([
        #("Case", json.string("SerializableContinuous")),
        #("Fields", json.array([field], function.identity)),
      ])
    }
  }
}

fn discrete_field_decoder() -> Decoder(Attribute) {
  dynamic.decode2(
    fn(key, values) { Discrete(key, zlist.of_list(values)) },
    dynamic.field("key", dynamic.string),
    dynamic.field("values", dynamic.list(dynamic.string)),
  )
}

fn continuous_field_decoder() -> Decoder(Attribute) {
  dynamic.decode3(
    Continuous,
    dynamic.field("key", dynamic.string),
    dynamic.field("min", dynamic.float),
    dynamic.field("max", dynamic.float),
  )
}

pub fn decoder() -> Decoder(Attribute) {
  dynamic.decode2(
    fn(case_val, fields) {
      case #(case_val, fields) {
        #("SerializableDiscrete", [discrete]) -> discrete
        #("SerializableContinuous", [continuous]) -> continuous
      }
    },
    dynamic.field("Case", dynamic.string),
    dynamic.field(
      "Fields",
      dynamic.list(dynamic.any([
        discrete_field_decoder(),
        continuous_field_decoder(),
      ])),
    ),
  )
}

pub fn realized(attr: Attribute) -> Attribute {
  case attr {
    Discrete(_, values) -> zlist.to_list(values)
    Continuous(_, _, _) -> []
  }
  attr
}
