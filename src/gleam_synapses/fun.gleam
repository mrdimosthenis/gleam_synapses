import gleam_synapses/model/net_elems/activation/activation

pub type Fun =
  activation.Activation

pub fn sigmoid() -> Fun {
  activation.Sigmoid
}

pub fn identity() -> Fun {
  activation.Identity
}

pub fn tanh() -> Fun {
  activation.Tanh
}

pub fn leaky_re_lu() -> Fun {
  activation.LeakyReLU
}
