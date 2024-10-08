import gleam_synapses/net.{type Net}
import gleeunit/should
import utils/large_values

fn layers() -> List(Int) {
  [4, 6, 5, 3]
}

fn my_neural_network() -> Net {
  net.new_with_seed(layers(), 1000)
}

fn input_values() -> List(Float) {
  [1.0, 0.5625, 0.511111, 0.47619]
}

fn prediction() -> List(Float) {
  net.predict(my_neural_network(), input_values())
}

const learning_rate = 0.99

fn expected_output() -> List(Float) {
  [0.2, 0.8, 0.01]
}

fn my_fit_network() -> Net {
  net.fit(my_neural_network(), learning_rate, input_values(), expected_output())
}

pub fn neural_network_to_json_test() {
  my_neural_network()
  |> net.to_json
  |> should.equal(large_values.seed_neural_network_json)
}

pub fn neural_network_prediction_test() {
  prediction()
  |> should.equal([0.4185136784147341, 0.33129940340020586, 0.7684439784413304])
}

pub fn neural_network_normal_errors_test() {
  net.errors(my_neural_network(), input_values(), expected_output(), False)
  |> should.equal([
    0.027456976474005072, 0.015444549266627855, 0.014033562702605208,
    0.013074737627156476,
  ])
}

pub fn neural_network_zero_errors_test() {
  net.errors(my_neural_network(), input_values(), prediction(), False)
  |> should.equal([0.0, 0.0, 0.0, 0.0])
}

pub fn fit_neural_network_prediction_test() {
  net.predict(my_fit_network(), input_values())
  |> should.equal([0.3881436258078948, 0.39200417715154473, 0.7024839489971717])
}
