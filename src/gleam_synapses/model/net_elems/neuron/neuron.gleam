import gleam_zlists.{ZList} as zlist
import minigen.{Generator}
import gleam_synapses/model/mathematics as maths
import gleam_synapses/model/net_elems/activation/activation.{Activation}

pub type Neuron {
  Neuron(activation_f: Activation, weights: ZList(Float))
}

pub fn init(
  input_size: Int,
  activation_f: Activation,
  weight_init_f: fn() -> Float,
) -> Neuron {
  let weights =
    zlist.indices()
    |> zlist.take(input_size + 1)
    |> zlist.map(fn(_) { weight_init_f() })

  Neuron(activation_f: activation_f, weights: weights)
}

pub fn output(neuron: Neuron, input_val: ZList(Float)) {
  let activation_input =
    input_val
    |> zlist.cons(1.0)
    |> maths.dot_product(neuron.weights)

  activation.f(neuron.activation_f)(activation_input)
}

pub fn back_propagated(
  neuron: Neuron,
  learning_rate: Float,
  input_val: ZList(Float),
  output_with_error: #(Float, Float),
) -> #(ZList(Float), Neuron) {
  let #(output_val, error) = output_with_error
  let output_inverse = activation.inverse(neuron.activation_f)(output_val)
  let common = error *. activation.deriv(neuron.activation_f)(output_inverse)
  let in_errors = zlist.map(input_val, fn(x) { x *. common })
  let new_weights =
    input_val
    |> zlist.cons(1.0)
    |> zlist.zip(neuron.weights)
    |> zlist.map(fn(x) {
      let #(a, b) = x
      b -. learning_rate *. common *. a
    })
  let new_neuron = Neuron(neuron.activation_f, new_weights)
  #(in_errors, new_neuron)
}

pub fn generator(input_size: Int) -> Generator(Neuron) {
  let weights_generator =
    minigen.float()
    |> minigen.map(fn(x) { 1.0 -. 2.0 *. x })
    |> minigen.list(input_size + 1)
    |> minigen.map(zlist.of_list)

  minigen.map2(activation.generator(), weights_generator, Neuron)
}
