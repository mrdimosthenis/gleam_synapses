import gleeunit/should
import minigen
import utils/large_values
import gleam_synapses/fun.{type Fun}
import gleam_synapses/net.{type Net}

fn my_neural_network() -> Net {
  net.from_json(large_values.customized_neural_network_json)
}

fn input_values() -> List(Float) {
  [1.0, 0.5625, 0.511111, 0.47619]
}

fn expected_output() -> List(Float) {
  [0.4, 0.05, 0.2]
}

fn prediction() -> List(Float) {
  net.par_predict(my_neural_network(), input_values())
}

const learning_rate = 0.01

fn my_fit_network() -> Net {
  net.par_fit(
    my_neural_network(),
    learning_rate,
    input_values(),
    expected_output(),
  )
}

pub fn neural_network_of_to_json_test() {
  let layers = fn() -> List(Int) { [4, 6, 8, 5, 3] }

  let activation_f = fn(layer_index: Int) -> Fun {
    case layer_index {
      0 -> fun.sigmoid()
      1 -> fun.identity()
      2 -> fun.leaky_re_lu()
      3 -> fun.tanh()
      _ -> panic as "More layers than expected"
    }
  }

  let weight_init_f = fn(_: Int) -> Float {
    minigen.float()
    |> minigen.run()
  }

  let just_created_neural_network_json =
    net.new_custom(layers(), activation_f, weight_init_f)
    |> net.to_json

  just_created_neural_network_json
  |> net.from_json
  |> net.to_json
  |> should.equal(just_created_neural_network_json)
}

pub fn neural_network_prediction_test() {
  should.equal(
    prediction(),
    [-0.013959435951885571, -0.16770539176070537, 0.6127887629040738],
  )
}

pub fn neural_network_normal_errors_test() {
  net.errors(my_neural_network(), input_values(), expected_output(), True)
  |> should.equal([
    -0.18229373795952453, -0.10254022760223255, -0.09317233470223055, -0.086806455078946,
  ])
}

pub fn neural_network_zero_errors_test() {
  net.errors(my_neural_network(), input_values(), prediction(), True)
  |> should.equal([0.0, 0.0, 0.0, 0.0])
}

pub fn fit_neural_network_prediction_test() {
  net.par_predict(my_fit_network(), input_values())
  |> should.equal([
    -0.006109464554743645, -0.1770428172237149, 0.6087944183600162,
  ])
}

pub fn neural_network_to_svg_test() {
  my_neural_network()
  |> net.to_svg
  |> should.equal(large_values.customized_neural_network_svg)
}
