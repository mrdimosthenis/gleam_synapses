import gleam/dynamic.{Decoder}
import gleam_zlists as zlist
import gleam/json.{Json}
import gleam_synapses/model/net_elems/layer/layer_serialized.{LayerSerialized}
import gleam_synapses/model/net_elems/network/network.{Network}


type NetworkSerialized =
  List(LayerSerialized)

pub fn serialized(network: Network) -> NetworkSerialized {
  network
  |> zlist.map(layer_serialized.serialized)
  |> zlist.to_list
}

fn deserialized(network_serialized: NetworkSerialized) -> Network {
  network_serialized
  |> zlist.of_list
  |> zlist.map(layer_serialized.deserialized)
}

fn json_encoded(network_serialized: NetworkSerialized) -> Json {
  json.array(network_serialized, layer_serialized.json_encoded)
}

fn json_decoder() -> Decoder(NetworkSerialized) {
  dynamic.list(layer_serialized.json_decoder())
}

pub fn to_json(network: Network) -> String {
  network
  |> serialized
  |> json_encoded
  |> json.to_string
}

pub fn of_json(s: String) -> Network {
  assert Ok(res) = json.decode(s, json_decoder())
  deserialized(res)
}

pub fn realized(network: Network) -> Network {
  serialized(network)
  network
}
