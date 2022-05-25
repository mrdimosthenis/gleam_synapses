import gleam/map.{Map}
import gleam/pair
import gleam_zlists.{ZList} as zlist
import gleam/dynamic
import gleam/function
import gleam/json
import gleam/iterator.{Iterator, Next}
import gleam_synapses/model/encoding/attribute/attribute.{
  Attribute, Continuous, Discrete,
}
import gleam_synapses/model/encoding/attribute/attribute_serialized

pub type Preprocessor =
  ZList(Attribute)

pub fn init(
  keys_with_flags: ZList(#(String, Bool)),
  dataset: Iterator(Map(String, String)),
) -> Preprocessor {
  assert Next(head, tail) = iterator.step(dataset)
  keys_with_flags
  |> zlist.map(fn(t) {
    let #(key, is_distinct) = t
    assert Ok(str_val) = map.get(head, key)
    case is_distinct {
      True -> Discrete(key, zlist.singleton(str_val))
      False -> {
        let v = attribute.parse(str_val)
        Continuous(key, v, v)
      }
    }
  })
  |> iterator.fold(
    tail,
    _,
    fn(acc, x) {
      zlist.map(acc, fn(attr) { attribute.updated(attr, x) })
    },
  )
}

pub fn encode(
  preprocessor: Preprocessor,
  datapoint: Map(String, String),
) -> ZList(Float) {
  zlist.flat_map(
    preprocessor,
    fn(attr) {
      let key = case attr {
        Discrete(k, _) -> k
        Continuous(k, _, _) -> k
      }
      assert Ok(v) = map.get(datapoint, key)
      attribute.encode(attr, v)
    },
  )
}

fn decode_acc_f(
  attr: Attribute,
  acc: #(ZList(Float), ZList(#(String, String))),
) -> #(ZList(Float), ZList(#(String, String))) {
  let #(unprocessed_floats, processed_ks_vs) = acc
  let #(key, split_index) = case attr {
    Discrete(key, values) -> #(key, zlist.count(values))
    Continuous(key, _, _) -> #(key, 1)
  }
  let #(encoded_values_ls, next_floats_zls) =
    zlist.split(unprocessed_floats, split_index)
  let decoded_value =
    encoded_values_ls
    |> zlist.of_list
    |> attribute.decode(attr, _)
  let next_ks_vs = zlist.cons(processed_ks_vs, #(key, decoded_value))
  #(next_floats_zls, next_ks_vs)
}

pub fn decode(
  preprocessor: Preprocessor,
  encoded_datapoint: ZList(Float),
) -> Map(String, String) {
  preprocessor
  |> zlist.reduce(
    #(encoded_datapoint, zlist.new()),
    fn(x, acc) { decode_acc_f(x, acc) },
  )
  |> pair.second
  |> zlist.to_list
  |> map.from_list
}

pub fn to_json(preprocessor: Preprocessor) -> String {
  preprocessor
  |> zlist.map(attribute_serialized.serialized)
  |> zlist.to_list
  |> json.array(function.identity)
  |> json.to_string
}

pub fn of_json(s: String) -> Preprocessor {
  assert Ok(res) =
    attribute_serialized.decoder()
    |> dynamic.list()
    |> json.decode(s, _)
  zlist.of_list(res)
}

pub fn realized(preprocessor: Preprocessor) -> Preprocessor {
  preprocessor
  |> zlist.map(attribute_serialized.realized)
  |> zlist.to_list
  preprocessor
}
