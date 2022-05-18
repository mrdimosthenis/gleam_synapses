import gleam/iterator.{Iterator}
import gleam/map.{Map}
import gleam_zlists as zlist
import gleam_synapses/model/encoding/serialization
import gleam_synapses/model/encoding/preprocessor

pub type DataPreprocessor =
  serialization.Preprocessor

pub fn init(
  keys_with_discrete_flags: List(#(String, Bool)),
  datapoints: Iterator(Map(String, String)),
) -> DataPreprocessor {
  let keys_with_flags = zlist.of_list(keys_with_discrete_flags)
  let data = zlist.of_iterator(datapoints)
  preprocessor.init(keys_with_flags, data)
}

pub fn encoded_datapoint(
  data_preprocessor: DataPreprocessor,
  datapoint: Map(String, String),
) -> List(Float) {
  preprocessor.encode(data_preprocessor, datapoint)
  |> zlist.to_list
}

pub fn decoded_datapoint(
  data_preprocessor: DataPreprocessor,
  encoded_values: List(Float),
) -> Map(String, String) {
  let values = zlist.of_list(encoded_values)
  preprocessor.decode(data_preprocessor, values)
}

pub fn to_json(data_preprocessor: DataPreprocessor) -> String {
  preprocessor.to_json(data_preprocessor)
}

pub fn of_json(json: String) -> DataPreprocessor {
  preprocessor.of_json(json)
}
