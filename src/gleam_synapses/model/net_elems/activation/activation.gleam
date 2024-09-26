import gleam/function
import gleam_synapses/model/mathematics
import minigen.{type Generator}

pub type Activation {
  Sigmoid
  Identity
  Tanh
  LeakyReLU
}

fn sigmoid_f(x: Float) -> Float {
  1.0 /. { 1.0 +. mathematics.exp(0.0 -. x) }
}

pub fn f(activation: Activation) -> fn(Float) -> Float {
  case activation {
    Sigmoid -> sigmoid_f
    Identity -> function.identity
    Tanh -> mathematics.tanh
    LeakyReLU -> fn(x) {
      case x <. 0.0 {
        True -> 0.01 *. x
        False -> x
      }
    }
  }
}

pub fn deriv(activation: Activation) -> fn(Float) -> Float {
  case activation {
    Sigmoid -> fn(d) { sigmoid_f(d) *. { 1.0 -. sigmoid_f(d) } }
    Identity -> fn(_) { 1.0 }
    Tanh -> fn(d) { 1.0 -. mathematics.tanh(d) *. mathematics.tanh(d) }
    LeakyReLU -> fn(d) {
      case d <. 0.0 {
        True -> 0.01
        False -> 1.0
      }
    }
  }
}

pub fn inverse(activation: Activation) -> fn(Float) -> Float {
  case activation {
    Sigmoid -> fn(y) {
      let t = y /. { 1.0 -. y }
      mathematics.log(t)
    }
    Identity -> function.identity
    Tanh -> fn(y) { 0.5 *. mathematics.log({ 1.0 +. y } /. { 1.0 -. y }) }
    LeakyReLU -> fn(y) {
      case y <. 0.0 {
        True -> y /. 0.01
        False -> y
      }
    }
  }
}

pub fn generator() -> Generator(Activation) {
  minigen.always(Sigmoid)
}
