import gleeunit/should
import minigen
import utils/large_values
import gleam_synapses/activation_function.{ActivationFunction}
import gleam_synapses/neural_network.{NeuralNetwork}

fn my_neural_network() -> NeuralNetwork {
  neural_network.of_json(large_values.customized_neural_network_json)
}

fn input_values() -> List(Float) {
  [1.0, 0.5625, 0.511111, 0.47619]
}

fn expected_output() -> List(Float) {
  [0.4, 0.05, 0.2]
}

fn prediction() -> List(Float) {
  neural_network.prediction(my_neural_network(), input_values())
}

const learning_rate = 0.01

fn my_fit_network() -> NeuralNetwork {
  neural_network.fit(
    my_neural_network(),
    learning_rate,
    input_values(),
    expected_output(),
  )
}

pub fn neural_network_of_to_json_test() {
  let layers = fn() -> List(Int) { [4, 6, 5, 3] }

  let activation_f = fn(layer_index: Int) -> ActivationFunction {
    case layer_index {
      0 -> activation_function.sigmoid()
      1 -> activation_function.identity()
      2 -> activation_function.leaky_re_lu()
      _ -> activation_function.tanh()
    }
  }

  let weight_init_f = fn(_: Int) -> Float {
    minigen.float()
    |> minigen.run()
  }

  let just_created_neural_network_json =
    neural_network.customized_init(layers(), activation_f, weight_init_f)
    |> neural_network.to_json

  just_created_neural_network_json
  |> neural_network.of_json
  |> neural_network.to_json
  |> should.equal(just_created_neural_network_json)
}

pub fn neural_network_prediction_test() {
  should.equal(
    prediction(),
    [-0.013959435951885419, -0.16770539176070562, 0.6127887629040737],
  )
}

pub fn neural_network_normal_errors_test() {
  neural_network.errors(
    my_neural_network(),
    learning_rate,
    input_values(),
    expected_output(),
  )
  |> should.equal([
    -0.18229373795952497, -0.10254022760223279, -0.09317233470223074, -0.08680645507894617,
  ])
}

pub fn neural_network_zero_errors_test() {
  neural_network.errors(
    my_neural_network(),
    learning_rate,
    input_values(),
    prediction(),
  )
  |> should.equal([0.0, 0.0, 0.0, 0.0])
}

pub fn fit_neural_network_prediction_test() {
  neural_network.prediction(my_fit_network(), input_values())
  |> should.equal([
    -0.006109464554744089, -0.17704281722371465, 0.6087944183600162,
  ])
}

pub fn neural_network_to_svg_test() {
  my_neural_network()
  |> neural_network.to_svg
  |> should.equal(large_values.customized_neural_network_svg)
}
