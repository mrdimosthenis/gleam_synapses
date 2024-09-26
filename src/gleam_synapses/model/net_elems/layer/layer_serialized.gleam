import gleam/dynamic.{type Decoder}
import gleam/json.{type Json}
import gleam_synapses/model/net_elems/layer/layer.{type Layer}
import gleam_synapses/model/net_elems/neuron/neuron_serialized.{
  type NeuronSerialized,
}
import gleam_zlists as zlist

pub type LayerSerialized =
  List(NeuronSerialized)

pub fn serialized(layer: Layer) -> LayerSerialized {
  layer
  |> zlist.map(neuron_serialized.serialized)
  |> zlist.to_list
}

pub fn deserialized(layer_serialized: LayerSerialized) -> Layer {
  layer_serialized
  |> zlist.of_list
  |> zlist.map(neuron_serialized.deserialized)
}

pub fn json_encoded(layer_serialized: LayerSerialized) -> Json {
  json.array(layer_serialized, neuron_serialized.json_encoded)
}

pub fn json_decoder() -> Decoder(LayerSerialized) {
  dynamic.list(neuron_serialized.json_decoder())
}
