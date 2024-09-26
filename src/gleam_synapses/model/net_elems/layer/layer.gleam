import gleam_synapses/model/net_elems/activation/activation.{type Activation}
import gleam_synapses/model/net_elems/neuron/neuron.{type Neuron}
import gleam_zlists.{type ZList} as zlist
import minigen.{type Generator}

@external(erlang, "native_parmap", "parmap")
fn parmap(x: List(a), y: fn(a) -> b) -> List(b)

fn pmap(zl: ZList(a), f: fn(a) -> b) -> ZList(b) {
  zl
  |> zlist.to_list
  |> parmap(f)
  |> zlist.of_list
}

pub type Layer =
  ZList(Neuron)

pub fn init(
  input_size: Int,
  output_size: Int,
  activation_f: Activation,
  weight_init_f: fn() -> fn() -> Float,
) -> Layer {
  zlist.indices()
  |> zlist.take(output_size)
  |> zlist.map(fn(_) { neuron.init(input_size, activation_f, weight_init_f()) })
}

pub fn output(
  layer: Layer,
  input_val: ZList(Float),
  in_parallel: Bool,
) -> ZList(Float) {
  case in_parallel {
    True -> pmap(layer, fn(x) { neuron.output(x, input_val) })
    False -> zlist.map(layer, fn(x) { neuron.output(x, input_val) })
  }
}

pub fn back_propagated(
  layer: Layer,
  learning_rate: Float,
  input_val: ZList(Float),
  output_with_error: ZList(#(Float, Float)),
  in_parallel: Bool,
) -> #(ZList(Float), Layer) {
  let f = fn(t) {
    let #(a, b) = t
    neuron.back_propagated(b, learning_rate, input_val, a)
  }

  let #(errors_multi, new_layer) = case in_parallel {
    True ->
      zlist.zip(output_with_error, layer)
      |> pmap(f)
      |> zlist.unzip
    False ->
      zlist.zip(output_with_error, layer)
      |> zlist.map(f)
      |> zlist.unzip
  }

  let errors =
    zlist.reduce(
      errors_multi,
      zlist.indices()
        |> zlist.map(fn(_) { 0.0 }),
      fn(x, acc) {
        zlist.zip(acc, x)
        |> zlist.map(fn(t) {
          let #(a, b) = t
          a +. b
        })
      },
    )
  #(errors, new_layer)
}

pub fn generator(input_size: Int, output_size: Int) -> Generator(Layer) {
  neuron.generator(input_size)
  |> minigen.list(output_size)
  |> minigen.map(zlist.of_list)
}
