//// This namespace contains functions that are related to data-point encodeing and decoding.
////
//// One hot encoding is a process that turns discrete attributes into a list of 0.0 and 1.0.
//// Minmax normalization scales continuous attributes into values between 0.0 and 1.0.
////

import gleam/dict.{type Dict}
import gleam/iterator.{type Iterator}
import gleam_synapses/model/encoding/preprocessor
import gleam_zlists as zlist

/// A codec can encode and decode every data point.
///
pub type Codec =
  preprocessor.Preprocessor

/// Creates a codec that can encode and decode every data point.
/// `attributes` is a list of pairs that define the name and the type (discrete or not) of each attribute.
///
/// ```gleam
/// let attributes = [#("petal_length", False), #("species", True)]
/// let setosa = dict.from_list([#("petal_length", "1.5"), #("species","setosa")])
/// let versicolor = dict.from_list([#("petal_length", "3.8"), #("species","versicolor")])
/// let data_points = iterator.from_list([setosa, versicolor])
/// let cdc = codec.new(attributes, data_points)
/// ```
///
pub fn new(
  attributes: List(#(String, Bool)),
  data_points: Iterator(Dict(String, String)),
) -> Codec {
  attributes
  |> zlist.of_list
  |> preprocessor.init(data_points)
  |> preprocessor.realized
}

/// Accepts the `data_point` as a map of strings and returns the encoded data point
/// as a list of float numbers between 0.0 and 1.0.
///
/// ```gleam
/// codec.encode(cdc, setosa)
/// [0.0, 1.0, 0.0]
/// ```
///
pub fn encode(codec: Codec, data_point: Dict(String, String)) -> List(Float) {
  codec
  |> preprocessor.encode(data_point)
  |> zlist.to_list
}

/// Accepts the `encoded_values` as a list of numbers between 0.0 and 1.0
/// and returns the decoded data point as a map of strings.
///
/// ```gleam
/// cdc
/// |> codec.decode([0.0, 1.0, 0.0])
/// |> dict.to_list
/// [#("petal_length", "1.5"), #("species","setosa")]
/// ```
///
pub fn decode(codec: Codec, encoded_values: List(Float)) -> Dict(String, String) {
  let values = zlist.of_list(encoded_values)
  preprocessor.decode(codec, values)
}

/// The JSON representation of the `codec`.
pub fn to_json(codec: Codec) -> String {
  preprocessor.to_json(codec)
}

/// Parses and returns a codec.
///
pub fn from_json(json: String) -> Codec {
  json
  |> preprocessor.of_json
  |> preprocessor.realized
}
