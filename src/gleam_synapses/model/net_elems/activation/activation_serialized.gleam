import gleam/dynamic.{Decoder}
import gleam/json.{Json}
import gleam_synapses/model/net_elems/activation/activation.{
  Activation, Identity, LeakyReLU, Sigmoid, Tanh,
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
  }
}

pub fn json_encoded(activation_serialised: ActivationSerialized) -> Json {
  json.string(activation_serialised)
}

pub fn json_decoder() -> Decoder(ActivationSerialized) {
  dynamic.string
}
