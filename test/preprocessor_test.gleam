import gleam/should
import gleam/int
import gleam/float
import gleam/string
import gleam/list
import gleam/iterator.{Iterator, Next}
import gleam/map.{Map}
import gleam_zlists as zlist
import utils/csv
import utils/large_values
import gleam_synapses/model/encoding/continuous_attribute
import gleam_synapses/data_preprocessor.{DataPreprocessor}

fn datapoints() -> Iterator(Map(String, String)) {
  csv.iterator_of_hmaps(large_values.mnist_dataset)
}

fn keys_with_discrete_flags() -> List(tuple(String, Bool)) {
  zlist.indices()
  |> zlist.map(fn(i) {
    let key = string.append("pixel", int.to_string(i))
    tuple(key, False)
  })
  |> zlist.take(784)
  |> zlist.cons(tuple("label", True))
  |> zlist.to_list
}

fn just_created_preprocessor() -> DataPreprocessor {
  data_preprocessor.init(keys_with_discrete_flags(), datapoints())
}

pub fn just_created_preprocessor_json() -> String {
  just_created_preprocessor()
  |> data_preprocessor.to_json
}

pub fn just_recreated_preprocessor_json() -> String {
  just_created_preprocessor_json()
  |> data_preprocessor.of_json
  |> data_preprocessor.to_json
}

fn my_preprocessor() -> DataPreprocessor {
  data_preprocessor.of_json(large_values.my_preprocessor_json)
}

fn first_datapoint() -> Map(String, String) {
  let Next(res, _) = iterator.step(datapoints())
  res
}

fn first_encoded_datapoint() -> List(Float) {
  data_preprocessor.encoded_datapoint(my_preprocessor(), first_datapoint())
}

fn first_decoded_datapoint_values() -> List(Float) {
  my_preprocessor()
  |> data_preprocessor.decoded_datapoint(first_encoded_datapoint())
  |> map.to_list
  |> list.sort(fn(t1, t2) {
    let tuple(k1, _) = t1
    let tuple(k2, _) = t2
    string.compare(k1, k2)
  })
  |> list.map(fn(t) {
    let tuple(_, v) = t
    continuous_attribute.parse(v)
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
