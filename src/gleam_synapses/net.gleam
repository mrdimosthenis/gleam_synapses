//// This namespace contains functions that are related to the neural networks.

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam_synapses/fun.{type Fun}
import gleam_synapses/model/draw
import gleam_synapses/model/net_elems/network/network
import gleam_synapses/model/net_elems/network/network_serialized
import gleam_zlists as zlist
import minigen

pub type Net =
  network.Network

fn seed_init(maybe_seed: Option(Int), layers: List(Int)) -> Net {
  let gen =
    layers
    |> zlist.of_list
    |> network.generator
  case maybe_seed {
    Some(i) -> minigen.run_with_seed(gen, i)
    None -> minigen.run(gen)
  }
}

fn fail_if_input_not_match(net: Net, input_values: List(Float)) -> Nil {
  let num_of_input_vals = list.length(input_values)
  let assert Ok(first_neuron) =
    net
    |> zlist.head
    |> result.then(zlist.head)
  let input_layer_size = zlist.count(first_neuron.weights) - 1
  let is_equal = num_of_input_vals == input_layer_size
  // TODO: provide the reason of the failure
  let assert True = is_equal
  Nil
}

fn fail_if_expected_not_match(net: Net, expected_output: List(Float)) -> Nil {
  let num_of_expected_vals = list.length(expected_output)
  let assert Ok(output_layer_size) =
    net
    |> zlist.reverse
    |> zlist.head
    |> result.map(zlist.count)
  let is_equal = num_of_expected_vals == output_layer_size
  // TODO: provide the reason of the failure
  let assert True = is_equal
  Nil
}

/// Creates a random neural network by accepting its layer sizes.
///
/// ```gleam
/// net.new([3, 4, 2])
/// ```
///
pub fn new(layers: List(Int)) -> Net {
  seed_init(None, layers)
  |> network_serialized.realized
}

/// Creates a non-random neural network by accepting its layer sizes and a seed.
/// `seed` is the number used to initialize the internal pseudorandom number generator.
///
/// ```gleam
/// net.new([3, 4, 2], 1000)
/// ```
///
pub fn new_with_seed(layers: List(Int), seed: Int) -> Net {
  seed_init(Some(seed), layers)
  |> network_serialized.realized
}

/// Creates a neural network by accepting the size, the activation function and the weights for each layer.
///
/// ```gleam
/// net.new_custom([3, 4, 2], fn(_){fun.sigmoid()}, fn(_){float.random(0.0, 1.0)})
/// ```
///
pub fn new_custom(
  layers: List(Int),
  activation_f: fn(Int) -> Fun,
  weight_init_f: fn(Int) -> Float,
) -> Net {
  layers
  |> zlist.of_list
  |> network.init(activation_f, weight_init_f)
  |> network_serialized.realized
}

/// Makes a prediction for the provided input.
/// The size of the returned list should be equal to the size of the output layer.
///
/// `input_values` should be the list that contains the values of the features.
/// Its size should be equal to the size of the input layer.
///
pub fn predict(net: Net, input_values: List(Float)) -> List(Float) {
  fail_if_input_not_match(net, input_values)
  let input = zlist.of_list(input_values)
  network.output(net, input, False)
  |> zlist.to_list
}

/// Calculates the prediction for the provided input in parallel.
/// It's usefull for neural networks with huge layers.
///
pub fn par_predict(net: Net, input_values: List(Float)) -> List(Float) {
  fail_if_input_not_match(net, input_values)
  let input = zlist.of_list(input_values)
  network.output(net, input, True)
  |> zlist.to_list
}

pub fn errors(
  net: Net,
  input_values: List(Float),
  expected_output: List(Float),
  in_parallel: Bool,
) -> List(Float) {
  fail_if_input_not_match(net, input_values)
  fail_if_expected_not_match(net, expected_output)
  let input = zlist.of_list(input_values)
  let expected = zlist.of_list(expected_output)
  network.errors(net, input, expected, in_parallel)
  |> zlist.to_list
}

/// Returns the neural network with its weights adjusted to the provided observation.
///
/// `learning_rate` is a number that controls how much the weights are adjusted to the observation.
/// `input_values` is the feature values of the observation and its size should be equal to the size of the input layer.
/// `expected_output` is the expected output of the observation and its size should be equal to the size of the output layer.
///
/// In order for a network to be fully trained, it should fit with multiple observations, usually by folding over an iterator.
///
pub fn fit(
  net: Net,
  learning_rate: Float,
  input_values: List(Float),
  expected_output: List(Float),
) -> Net {
  fail_if_input_not_match(net, input_values)
  fail_if_expected_not_match(net, expected_output)
  let input = zlist.of_list(input_values)
  let expected = zlist.of_list(expected_output)
  network.fit(net, learning_rate, input, expected, False)
  |> network_serialized.realized
}

/// Returns the neural network with its weights adjusted to the provided observation.
///
/// The calculation is performed in parallel.
/// When the neural network has huge layers, the parallel calculation boosts the performance.
///
pub fn par_fit(
  net: Net,
  learning_rate: Float,
  input_values: List(Float),
  expected_output: List(Float),
) -> Net {
  fail_if_input_not_match(net, input_values)
  fail_if_expected_not_match(net, expected_output)
  let input = zlist.of_list(input_values)
  let expected = zlist.of_list(expected_output)
  network.fit(net, learning_rate, input, expected, True)
  |> network_serialized.realized
}

/// The JSON representation of the neural network.
///
pub fn to_json(net: Net) -> String {
  network_serialized.to_json(net)
}

/// Parses and returns a neural network.
///
/// ```gleam
/// net.from_json("[[{\"activationF\":\"sigmoid\",\"weights\":[-0.4,-0.1,-0.8]}]]")
/// ```
///
pub fn from_json(json: String) -> Net {
  json
  |> network_serialized.of_json
  |> network_serialized.realized
}

/// Returns the SVG representation of the neural network.
///
/// The color of each neuron depends on its activation function
/// while the transparency of the synapses depends on their weight.
///
pub fn to_svg(net: Net) -> String {
  draw.network_svg(net)
}
