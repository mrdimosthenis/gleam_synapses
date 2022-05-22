import gleam/dynamic.{Decoder}
import gleam_zlists as zlist
import gleam/json.{Json}
import gleam_synapses/model/net_elems/activation/activation_serialized.{
  ActivationSerialized,
}
import gleam_synapses/model/net_elems/neuron/neuron.{Neuron}

pub type NeuronSerialized {
  NeuronSerialized(activation_f: ActivationSerialized, weights: List(Float))
}

pub fn serialized(neuron: Neuron) -> NeuronSerialized {
  NeuronSerialized(
    activation_serialized.serialized(neuron.activation_f),
    zlist.to_list(neuron.weights),
  )
}

pub fn deserialized(neuron_serialized: NeuronSerialized) -> Neuron {
  Neuron(
    activation_serialized.deserialized(neuron_serialized.activation_f),
    zlist.of_list(neuron_serialized.weights),
  )
}

pub fn json_encoded(neuron_serialized: NeuronSerialized) -> Json {
  json.object([
    #(
      "activationF",
      activation_serialized.json_encoded(neuron_serialized.activation_f),
    ),
    #("weights", json.array(neuron_serialized.weights, json.float)),
  ])
}

pub fn json_decoder() -> Decoder(NeuronSerialized) {
  dynamic.decode2(
    NeuronSerialized,
    dynamic.field("activationF", activation_serialized.json_decoder()),
    dynamic.field("weights", dynamic.list(dynamic.float)),
  )
}
