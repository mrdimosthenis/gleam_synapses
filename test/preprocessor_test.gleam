import gleam/dict.{type Dict}
import gleam/int
import gleam/iterator.{type Iterator, Next}
import gleam/list
import gleam/string
import gleam_synapses/codec.{type Codec}
import gleam_synapses/model/encoding/attribute/attribute
import gleam_zlists as zlist
import gleeunit/should
import utils/csv
import utils/large_values

fn datapoints() -> Iterator(Dict(String, String)) {
  csv.iterator_of_hmaps(large_values.mnist_dataset)
}

fn keys_with_discrete_flags() -> List(#(String, Bool)) {
  zlist.indices()
  |> zlist.map(fn(i) {
    let key = string.append("pixel", int.to_string(i))
    #(key, False)
  })
  |> zlist.take(784)
  |> zlist.cons(#("label", True))
  |> zlist.to_list
}

fn just_created_preprocessor() -> Codec {
  codec.new(keys_with_discrete_flags(), datapoints())
}

pub fn just_created_preprocessor_json() -> String {
  just_created_preprocessor()
  |> codec.to_json
}

pub fn just_recreated_preprocessor_json() -> String {
  just_created_preprocessor_json()
  |> codec.from_json
  |> codec.to_json
}

fn my_preprocessor() -> Codec {
  codec.from_json(large_values.my_preprocessor_json)
}

fn first_datapoint() -> Dict(String, String) {
  let assert Next(res, _) = iterator.step(datapoints())
  res
}

fn first_encoded_datapoint() -> List(Float) {
  codec.encode(my_preprocessor(), first_datapoint())
}

fn first_decoded_datapoint_values() -> List(Float) {
  my_preprocessor()
  |> codec.decode(first_encoded_datapoint())
  |> dict.to_list
  |> list.sort(fn(t1, t2) {
    let #(k1, _) = t1
    let #(k2, _) = t2
    string.compare(k1, k2)
  })
  |> list.map(fn(t) {
    let #(_, v) = t
    attribute.parse(v)
  })
}

// native_preprocessor_test:just_created_preprocessor_json_test_()
// native_preprocessor_test:just_created_preprocessor_of_to_json_test_()
pub fn my_preprocessor_json() -> String {
  large_values.my_preprocessor_json
}

pub fn first_encoded_datapoint_test() {
  should.equal(
    large_values.expected_first_encoded_datapoint(),
    first_encoded_datapoint(),
  )
}

pub fn first_decoded_datapoint_values_test() {
  should.equal(
    large_values.expected_first_decoded_datapoint_values(),
    first_decoded_datapoint_values(),
  )
}
