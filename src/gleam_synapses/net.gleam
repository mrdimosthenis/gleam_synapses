import gleam/option.{None, Option, Some}
import gleam/list
import gleam/result
import gleam_zlists as zlist
import minigen
import gleam_synapses/model/net_elems/network/network
import gleam_synapses/model/net_elems/network/network_serialized
import gleam_synapses/model/draw
import gleam_synapses/fun.{Fun}

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
  assert Ok(first_neuron) =
    net
    |> zlist.head
    |> result.then(zlist.head)
  let input_layer_size = zlist.count(first_neuron.weights) - 1
  let is_equal = num_of_input_vals == input_layer_size
  // TODO: provide the reason of the failure
  assert True = is_equal
  Nil
}

fn fail_if_expected_not_match(net: Net, expected_output: List(Float)) -> Nil {
  let num_of_expected_vals = list.length(expected_output)
  assert Ok(output_layer_size) =
    net
    |> zlist.reverse
    |> zlist.head
    |> result.map(zlist.count)
  let is_equal = num_of_expected_vals == output_layer_size
  // TODO: provide the reason of the failure
  assert True = is_equal
  Nil
}

pub fn new(layers: List(Int)) -> Net {
  seed_init(None, layers)
  |> network_serialized.realized
}

pub fn new_with_seed(seed: Int, layers: List(Int)) -> Net {
  seed_init(Some(seed), layers)
  |> network_serialized.realized
}

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

pub fn predict(net: Net, input_values: List(Float)) -> List(Float) {
  fail_if_input_not_match(net, input_values)
  let input = zlist.of_list(input_values)
  network.output(net, input, False)
  |> zlist.to_list
}

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

pub fn to_json(net: Net) -> String {
  network_serialized.to_json(net)
}

pub fn from_json(json: String) -> Net {
  json
  |> network_serialized.of_json
  |> network_serialized.realized
}

pub fn to_svg(net: Net) -> String {
  draw.network_svg(net)
}
