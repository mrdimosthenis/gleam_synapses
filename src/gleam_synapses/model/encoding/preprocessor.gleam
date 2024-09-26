import gleam/dict.{type Dict}
import gleam/dynamic
import gleam/function
import gleam/iterator.{type Iterator, Next}
import gleam/json
import gleam/pair
import gleam_synapses/model/encoding/attribute/attribute.{
  type Attribute, Continuous, Discrete,
}
import gleam_synapses/model/encoding/attribute/attribute_serialized
import gleam_zlists.{type ZList} as zlist

pub type Preprocessor =
  ZList(Attribute)

pub fn init(
  keys_with_flags: ZList(#(String, Bool)),
  dataset: Iterator(Dict(String, String)),
) -> Preprocessor {
  let assert Next(head, tail) = iterator.step(dataset)
  keys_with_flags
  |> zlist.map(fn(t) {
    let #(key, is_distinct) = t
    let assert Ok(str_val) = dict.get(head, key)
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
    fn(acc, x) { zlist.map(acc, fn(attr) { attribute.updated(attr, x) }) },
  )
}

pub fn encode(
  preprocessor: Preprocessor,
  datapoint: Dict(String, String),
) -> ZList(Float) {
  zlist.flat_map(preprocessor, fn(attr) {
    let key = case attr {
      Discrete(k, _) -> k
      Continuous(k, _, _) -> k
    }
    let assert Ok(v) = dict.get(datapoint, key)
    attribute.encode(attr, v)
  })
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
) -> Dict(String, String) {
  preprocessor
  |> zlist.reduce(#(encoded_datapoint, zlist.new()), fn(x, acc) {
    decode_acc_f(x, acc)
  })
  |> pair.second
  |> zlist.to_list
  |> dict.from_list
}

pub fn to_json(preprocessor: Preprocessor) -> String {
  preprocessor
  |> zlist.map(attribute_serialized.serialized)
  |> zlist.to_list
  |> json.array(function.identity)
  |> json.to_string
}

pub fn of_json(s: String) -> Preprocessor {
  let assert Ok(res) =
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
