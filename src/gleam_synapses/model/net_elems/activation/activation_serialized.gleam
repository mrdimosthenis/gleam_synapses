import gleam/dynamic.{type Decoder}
import gleam/json.{type Json}
import gleam_synapses/model/net_elems/activation/activation.{
  type Activation, Identity, LeakyReLU, Sigmoid, Tanh,
}

pub type ActivationSerialized =
  String

pub fn serialized(activation: Activation) -> ActivationSerialized {
  case activation {
    Sigmoid -> "sigmoid"
    Identity -> "identity"
    Tanh -> "tanh"
    LeakyReLU -> "leakyReLU"
  }
}

pub fn deserialized(activation_serialized: ActivationSerialized) -> Activation {
  case activation_serialized {
    "sigmoid" -> Sigmoid
    "identity" -> Identity
    "tanh" -> Tanh
    "leakyReLU" -> LeakyReLU
    _ -> panic as "Unknown activation function"
  }
}

pub fn json_encoded(activation_serialised: ActivationSerialized) -> Json {
  json.string(activation_serialised)
}

pub fn json_decoder() -> Decoder(ActivationSerialized) {
  dynamic.string
}
