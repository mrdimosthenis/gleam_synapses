import gleam_synapses/model/net_elems/activation/activation

pub type ActivationFunction =
  activation.Activation

pub fn sigmoid() -> ActivationFunction {
  activation.Sigmoid
}

pub fn identity() -> ActivationFunction {
  activation.Identity
}

pub fn tanh() -> ActivationFunction {
  activation.Tanh
}

pub fn leaky_re_lu() -> ActivationFunction {
  activation.LeakyReLU
}
