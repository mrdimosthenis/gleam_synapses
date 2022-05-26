import gleam_synapses/model/net_elems/activation/activation

/// The activation function a neuron can have.
/// It can be used in the arguments of neural network's creation.
pub type Fun =
  activation.Activation

/// Sigmoid takes any value as input and outputs values in the range of 0.0 to 1.0.
pub fn sigmoid() -> Fun {
  activation.Sigmoid
}

/// Identity is a linear function where the output is equal to the input.
pub fn identity() -> Fun {
  activation.Identity
}

/// Tanh is similar to sigmoid, but outputs values in the range of -1.0 and 1.0.
pub fn tanh() -> Fun {
  activation.Tanh
}

/// LeakyReLU gives a small proportion of x if x is negative and x otherwise.
pub fn leaky_re_lu() -> Fun {
  activation.LeakyReLU
}
