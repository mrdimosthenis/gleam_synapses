import decode.{Decoder}
import gleam/jsone.{JsonValue}
import gleam_zlists.{ZList} as zlist
import minigen.{Generator}
import gleam_synapses/model/mathematics as maths
import gleam_synapses/model/net_elems/activation.{
  Activation, ActivationSerialized,
}

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
  neuron.activation_f
  |> activation.restricted_input(activation_input)
  |> neuron.activation_f.f
}

pub fn back_propagated(
  neuron: Neuron,
  learning_rate: Float,
  input_val: ZList(Float),
  output_with_error: tuple(Float, Float),
) -> tuple(ZList(Float), Neuron) {
  let tuple(output_val, error) = output_with_error
  let output_inverse = neuron.activation_f.inverse(output_val)
  let common = error *. neuron.activation_f.deriv(output_inverse)
  let in_errors = zlist.map(input_val, fn(x) { x *. common })
  let new_weights =
    input_val
    |> zlist.cons(1.0)
    |> zlist.zip(neuron.weights)
    |> zlist.map(fn(x) {
      let tuple(a, b) = x
      b -. learning_rate *. common *. a
    })
  let new_neuron = Neuron(neuron.activation_f, new_weights)
  tuple(in_errors, new_neuron)
}

pub type NeuronSerialized {
  NeuronSerialized(activation_f: ActivationSerialized, weights: List(Float))
}

pub fn serialized(neuron: Neuron) -> NeuronSerialized {
  NeuronSerialized(
    activation.serialized(neuron.activation_f),
    zlist.to_list(neuron.weights),
  )
}

pub fn deserialized(neuron_serialized: NeuronSerialized) -> Neuron {
  Neuron(
    activation.deserialized(neuron_serialized.activation_f),
    zlist.of_list(neuron_serialized.weights),
  )
}

pub fn json_encoded(neuron_serialized: NeuronSerialized) -> JsonValue {
  jsone.object([
    tuple(
      "activationF",
      activation.json_encoded(neuron_serialized.activation_f),
    ),
    tuple("weights", jsone.array(neuron_serialized.weights, jsone.float)),
  ])
}

pub fn json_decoder() -> Decoder(NeuronSerialized) {
  decode.map2(
    NeuronSerialized,
    decode.field("activationF", activation.json_decoder()),
    decode.field("weights", decode.list(decode.float())),
  )
}

pub fn generator(input_size: Int) -> Generator(Neuron) {
  let weights_generator =
    minigen.float()
    |> minigen.map(fn(x) { 1.0 -. 2.0 *. x })
    |> minigen.list(input_size + 1)
    |> minigen.map(zlist.of_list)

  minigen.map2(activation.generator(), weights_generator, Neuron)
}
