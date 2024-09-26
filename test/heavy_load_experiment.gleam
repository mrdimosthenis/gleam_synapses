import gleam_synapses/fun.{type Fun}
import gleam_synapses/net.{type Net}
import minigen

fn first_layer_size() -> Int {
  10000
}

fn last_layer_size() -> Int {
  3
}

fn network() -> Net {
  let layers = [first_layer_size(), 1000, last_layer_size()]

  let activation_f = fn(layer_index: Int) -> Fun {
    case layer_index {
      0 -> fun.identity()
      _ -> fun.leaky_re_lu()
    }
  }

  let weight_init_f = fn(_: Int) -> Float {
    minigen.float()
    |> minigen.run()
  }

  net.new_custom(layers, activation_f, weight_init_f)
}

fn random_input_values() -> List(Float) {
  minigen.float()
  |> minigen.list(first_layer_size())
  |> minigen.run
}

fn random_expected_values() -> List(Float) {
  minigen.float()
  |> minigen.list(last_layer_size())
  |> minigen.run
}

pub fn run() {
  network()
  |> net.fit(0.1, random_input_values(), random_expected_values())
  |> net.predict(random_input_values())
}

pub fn par_run() {
  network()
  |> net.par_fit(0.1, random_input_values(), random_expected_values())
  |> net.par_predict(random_input_values())
}
