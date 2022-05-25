import gleam/map.{Map}
import gleam/iterator.{Iterator}
import gleam_zlists.{ZList} as zlist
import gleeunit/should
import gleam_synapses/model/encoding/preprocessor.{Preprocessor}

fn datapoint_1() -> Map(String, String) {
  [#("a", "a1"), #("b", "b1"), #("c", "-8.0"), #("d", "3")]
  |> map.from_list
}

fn datapoint_2() -> Map(String, String) {
  datapoint_1()
  |> map.insert("b", "b2")
}

fn datapoint_3() -> Map(String, String) {
  datapoint_1()
  |> map.insert("b", "b3")
}

fn datapoint_4() -> Map(String, String) {
  datapoint_1()
  |> map.insert("b", "b4")
  |> map.insert("d", "5.0")
}

fn datapoint_5() -> Map(String, String) {
  datapoint_1()
  |> map.insert("b", "b5")
  |> map.insert("d", "4.0")
}

fn dataset() -> Iterator(Map(String, String)) {
  [datapoint_1(), datapoint_2(), datapoint_3(), datapoint_4(), datapoint_5()]
  |> iterator.from_list
}

fn keys_with_flags() -> ZList(#(String, Bool)) {
  [#("a", True), #("b", True), #("c", False), #("d", False)]
  |> zlist.of_list
}

fn my_preprocessor() -> Preprocessor {
  preprocessor.init(keys_with_flags(), dataset())
}

fn encoded_dataset() -> ZList(ZList(Float)) {
  dataset()
  |> zlist.of_iterator
  |> zlist.map(fn(x) { preprocessor.encode(my_preprocessor(), x) })
}

fn decoded_dataset() -> ZList(Map(String, String)) {
  zlist.map(
    encoded_dataset(),
    fn(x) { preprocessor.decode(my_preprocessor(), x) },
  )
}

pub fn encode_dataset_test() {
  encoded_dataset()
  |> zlist.map(zlist.to_list)
  |> zlist.to_list
  |> should.equal([
    [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.5, 0.0],
    [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.5, 0.0],
    [1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.5, 0.0],
    [1.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.5, 1.0],
    [1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5],
  ])
}

pub fn decode_dataset_test() {
  decoded_dataset()
  |> zlist.to_list
  |> should.equal([
    map.from_list([#("a", "a1"), #("b", "b1"), #("c", "-8.0"), #("d", "3.0")]),
    map.from_list([#("a", "a1"), #("b", "b2"), #("c", "-8.0"), #("d", "3.0")]),
    map.from_list([#("a", "a1"), #("b", "b3"), #("c", "-8.0"), #("d", "3.0")]),
    map.from_list([#("a", "a1"), #("b", "b4"), #("c", "-8.0"), #("d", "5.0")]),
    map.from_list([#("a", "a1"), #("b", "b5"), #("c", "-8.0"), #("d", "4.0")]),
  ])
}

const json: String = "[{\"Case\":\"SerializableDiscrete\",\"Fields\":[{\"key\":\"a\",\"values\":[\"a1\"]}]},{\"Case\":\"SerializableDiscrete\",\"Fields\":[{\"key\":\"b\",\"values\":[\"b5\",\"b4\",\"b3\",\"b2\",\"b1\"]}]},{\"Case\":\"SerializableContinuous\",\"Fields\":[{\"key\":\"c\",\"min\":-8.0,\"max\":-8.0}]},{\"Case\":\"SerializableContinuous\",\"Fields\":[{\"key\":\"d\",\"min\":3.0,\"max\":5.0}]}]"

pub fn preprocessor_to_json_test() {
  my_preprocessor()
  |> preprocessor.to_json
  |> should.equal(json)
}

pub fn preprocessor_of_to_json_test() {
  json
  |> preprocessor.of_json
  |> preprocessor.to_json
  |> should.equal(json)
}
