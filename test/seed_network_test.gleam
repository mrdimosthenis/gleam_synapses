import gleeunit/should
import utils/large_values
import gleam_synapses/net.{Net}

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
  |> should.equal([0.7018483008852783, 0.5232699523175631, 0.746950953587391])
}

pub fn neural_network_normal_errors_test() {
  net.errors(my_neural_network(), input_values(), expected_output(), False)
  |> should.equal([
    0.07624623311148832, 0.042888506125212174, 0.0389702884518459, 0.036307693745359616,
  ])
}

pub fn neural_network_zero_errors_test() {
  net.errors(my_neural_network(), input_values(), prediction(), False)
  |> should.equal([0.0, 0.0, 0.0, 0.0])
}

pub fn fit_neural_network_prediction_test() {
  net.predict(my_fit_network(), input_values())
  |> should.equal([0.6335205999385805, 0.5756314596704061, 0.6599122411687741])
}
