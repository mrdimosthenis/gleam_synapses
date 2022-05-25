import gleam/iterator.{Iterator}
import gleam/map.{Map}
import gleam_zlists as zlist
import gleam_synapses/model/encoding/preprocessor

pub type Codec =
  preprocessor.Preprocessor

pub fn init(
  attributes_with_flags: List(#(String, Bool)),
  datapoints: Iterator(Map(String, String)),
) -> Codec {
  attributes_with_flags
  |> zlist.of_list
  |> preprocessor.init(datapoints)
  |> preprocessor.realized
}

pub fn encoded_datapoint(
  codec: Codec,
  datapoint: Map(String, String),
) -> List(Float) {
  codec
  |> preprocessor.encode(datapoint)
  |> zlist.to_list
}

pub fn decoded_datapoint(
  codec: Codec,
  encoded_values: List(Float),
) -> Map(String, String) {
  let values = zlist.of_list(encoded_values)
  preprocessor.decode(codec, values)
}

pub fn to_json(codec: Codec) -> String {
  preprocessor.to_json(codec)
}

pub fn from_json(json: String) -> Codec {
  json
  |> preprocessor.of_json
  |> preprocessor.realized
}
