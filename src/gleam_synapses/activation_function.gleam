import gleam_synapses/model/net_elems/activation

pub type ActivationFunction =
  activation.Activation

pub fn sigmoid() -> ActivationFunction {
  activation.sigmoid()
}

pub fn identity() -> ActivationFunction {
  activation.identity()
}

pub fn tanh() -> ActivationFunction {
  activation.tanh()
}

pub fn leaky_re_lu() -> ActivationFunction {
  activation.leaky_re_lu()
}
