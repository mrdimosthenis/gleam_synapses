import gleam/option.{None, Option, Some}
import gleam/list
import gleam/result
import gleam_zlists as zlist
import minigen
import gleam_synapses/model/net_elems/network as net
import gleam_synapses/model/draw
import gleam_synapses/activation_function.{ActivationFunction}

pub type NeuralNetwork =
  net.Network

fn seed_init(maybe_seed: Option(Int), layers: List(Int)) -> NeuralNetwork {
  let gen =
    layers
    |> zlist.of_list
    |> net.generator
  case maybe_seed {
    Some(i) -> minigen.run_with_seed(gen, i)
    None -> minigen.run(gen)
  }
}

fn fail_if_input_not_match(
  network: NeuralNetwork,
  input_values: List(Float),
) -> Nil {
  let num_of_input_vals = list.length(input_values)
  assert Ok(first_neuron) =
    network
    |> zlist.head
    |> result.then(zlist.head)
  let input_layer_size = zlist.count(first_neuron.weights) - 1
  let is_equal = num_of_input_vals == input_layer_size
  // TODO: provide the reason of the failure
  assert True = is_equal
  Nil
}

fn fail_if_expected_not_match(
  network: NeuralNetwork,
  expected_output: List(Float),
) -> Nil {
  let num_of_expected_vals = list.length(expected_output)
  assert Ok(output_layer_size) =
    network
    |> zlist.reverse
    |> zlist.head
    |> result.map(zlist.count)
  let is_equal = num_of_expected_vals == output_layer_size
  // TODO: provide the reason of the failure
  assert True = is_equal
  Nil
}

pub fn init(layers: List(Int)) -> NeuralNetwork {
  seed_init(None, layers)
}

pub fn init_with_seed(seed: Int, layers: List(Int)) -> NeuralNetwork {
  seed_init(Some(seed), layers)
}

pub fn customized_init(
  layers: List(Int),
  activation_f: fn(Int) -> ActivationFunction,
  weight_init_f: fn(Int) -> Float,
) -> NeuralNetwork {
  layers
  |> zlist.of_list
  |> net.init(activation_f, weight_init_f)
}

pub fn prediction(
  network: NeuralNetwork,
  input_values: List(Float),
) -> List(Float) {
  fail_if_input_not_match(network, input_values)
  let input = zlist.of_list(input_values)
  net.output(network, input)
  |> zlist.to_list
}

pub fn errors(
  network: NeuralNetwork,
  learning_rate: Float,
  input_values: List(Float),
  expected_output: List(Float),
) -> List(Float) {
  fail_if_input_not_match(network, input_values)
  fail_if_expected_not_match(network, expected_output)
  let input = zlist.of_list(input_values)
  let expected = zlist.of_list(expected_output)
  net.errors(network, learning_rate, input, expected)
  |> zlist.to_list
}

pub fn fit(
  network: NeuralNetwork,
  learning_rate: Float,
  input_values: List(Float),
  expected_output: List(Float),
) -> NeuralNetwork {
  fail_if_input_not_match(network, input_values)
  fail_if_expected_not_match(network, expected_output)
  let input = zlist.of_list(input_values)
  let expected = zlist.of_list(expected_output)
  net.fit(network, learning_rate, input, expected)
}

pub fn to_json(network: NeuralNetwork) -> String {
  net.to_json(network)
}

pub fn of_json(json: String) -> NeuralNetwork {
  net.of_json(json)
}

pub fn to_svg(network: NeuralNetwork) -> String {
  draw.network_svg(network)
}
