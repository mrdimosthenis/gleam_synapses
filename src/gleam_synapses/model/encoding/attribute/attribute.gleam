import gleam/float
import gleam/json
import gleam/int
import gleam/map.{Map}
import gleam/pair
import gleam/result
import gleam/string
import gleam_zlists.{ZList} as zlist

pub type Attribute {
  Discrete(key: String, values: ZList(String))
  Continuous(key: String, min: Float, max: Float)
}

pub fn parse(s: String) -> Float {
  let trimmed = string.trim(s)
  case #(float.parse(trimmed), int.parse(trimmed)) {
    #(Ok(x), _) -> x
    #(_, Ok(x)) -> int.to_float(x)
  }
}

pub fn updated(
  attribute: Attribute,
  datapoint: Map(String, String),
) -> Attribute {
  case attribute {
    Discrete(key, values) -> {
      assert Ok(v) = map.get(datapoint, key)
      let updated_values = case zlist.has_member(values, v) {
        True -> values
        False -> zlist.cons(values, v)
      }
      Discrete(key, updated_values)
    }
    Continuous(key, min, max) -> {
      assert Ok(v) =
        datapoint
        |> map.get(key)
        |> result.map(parse)
      Continuous(key, float.min(v, min), float.max(v, max))
    }
  }
}

pub fn encode(attribute: Attribute, value: String) -> ZList(Float) {
  case attribute {
    Discrete(_, values) ->
      values
      |> zlist.map(fn(x) {
        case x == value {
          True -> 1.0
          False -> 0.0
        }
      })
    Continuous(_, min, max) ->
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
}

pub fn decode(attribute: Attribute, encoded_values: ZList(Float)) -> String {
  case attribute {
    Discrete(_, values) -> {
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
    Continuous(_, min, max) ->
      case min == max {
        True -> min
        False -> {
          assert Ok(v) = zlist.head(encoded_values)
          let factor = max -. min
          v *. factor +. min
        }
      }
      |> json.float
      |> json.to_string
  }
}
