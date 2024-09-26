import gleam/pair
import gleam_synapses/model/net_elems/activation/activation.{type Activation}
import gleam_synapses/model/net_elems/layer/layer.{type Layer}
import gleam_zlists.{type ZList} as zlist
import minigen.{type Generator}

pub type Network =
  ZList(Layer)

pub fn init(
  layer_sizes: ZList(Int),
  activation_f: fn(Int) -> Activation,
  weight_init_f: fn(Int) -> Float,
) -> Network {
  let assert Ok(tl) = zlist.tail(layer_sizes)
  zlist.zip(layer_sizes, tl)
  |> zlist.with_index
  |> zlist.map(fn(t) {
    let #(#(lr_sz, next_lr_sz), index) = t
    layer.init(lr_sz, next_lr_sz, activation_f(index), fn() {
      fn() { weight_init_f(index) }
    })
  })
}

pub fn output(
  network: Network,
  input_val: ZList(Float),
  in_parallel: Bool,
) -> ZList(Float) {
  zlist.reduce(network, input_val, fn(x, acc) {
    layer.output(x, acc, in_parallel)
  })
}

fn fed_forward_acc_f(
  already_fed: ZList(#(ZList(Float), Layer)),
  next_layer: Layer,
  in_parallel: Bool,
) -> ZList(#(ZList(Float), Layer)) {
  let assert Ok(#(errors_val, layer_val)) = zlist.head(already_fed)
  let next_input = layer.output(layer_val, errors_val, in_parallel)
  zlist.cons(already_fed, #(next_input, next_layer))
}

fn fed_forward(
  network: Network,
  input_val: ZList(Float),
  in_parallel: Bool,
) -> ZList(#(ZList(Float), Layer)) {
  let assert Ok(#(net_hd, net_tl)) = zlist.uncons(network)
  let init_feed =
    #(input_val, net_hd)
    |> zlist.singleton
  zlist.reduce(net_tl, init_feed, fn(x, acc) {
    fed_forward_acc_f(acc, x, in_parallel)
  })
}

fn back_propagated_acc_f(
  learning_rate: Float,
  errors_with_already_propagated: #(ZList(Float), ZList(Layer)),
  input_with_layer: #(ZList(Float), Layer),
  in_parallel: Bool,
) -> #(ZList(Float), ZList(Layer)) {
  let #(errors_val, already_propagated) = errors_with_already_propagated
  let #(last_input, last_layer) = input_with_layer
  let last_output_with_errors =
    layer.output(last_layer, last_input, in_parallel)
    |> zlist.zip(errors_val)
  let #(next_errors, propagated_layer) =
    layer.back_propagated(
      last_layer,
      learning_rate,
      last_input,
      last_output_with_errors,
      in_parallel,
    )
  let next_already_propagated = zlist.cons(already_propagated, propagated_layer)
  #(next_errors, next_already_propagated)
}

fn back_propagated(
  learning_rate: Float,
  expected_output: ZList(Float),
  reversed_inputs_with_layers: ZList(#(ZList(Float), Layer)),
  in_parallel: Bool,
) -> #(ZList(Float), Network) {
  let assert Ok(#(#(last_input, last_layer), reversed_inputs_with_layers_tl)) =
    zlist.uncons(reversed_inputs_with_layers)
  let output_val = layer.output(last_layer, last_input, in_parallel)
  let errors_val =
    zlist.zip(output_val, expected_output)
    |> zlist.map(fn(t) {
      let #(a, b) = t
      a -. b
    })
  let output_with_errors = zlist.zip(output_val, errors_val)
  let #(init_errors, first_propagated) =
    layer.back_propagated(
      last_layer,
      learning_rate,
      last_input,
      output_with_errors,
      in_parallel,
    )
  let init_acc = #(init_errors, zlist.singleton(first_propagated))
  zlist.reduce(reversed_inputs_with_layers_tl, init_acc, fn(x, acc) {
    back_propagated_acc_f(learning_rate, acc, x, in_parallel)
  })
}

pub fn errors(
  network: Network,
  input_val: ZList(Float),
  expected_output: ZList(Float),
  in_parallel: Bool,
) -> ZList(Float) {
  network
  |> fed_forward(input_val, in_parallel)
  |> back_propagated(0.0, expected_output, _, in_parallel)
  |> pair.first
}

pub fn fit(
  network: Network,
  learning_rate: Float,
  input_val: ZList(Float),
  expected_output: ZList(Float),
  in_parallel: Bool,
) -> Network {
  network
  |> fed_forward(input_val, in_parallel)
  |> back_propagated(learning_rate, expected_output, _, in_parallel)
  |> pair.second
}

pub fn generator(layer_sizes: ZList(Int)) -> Generator(Network) {
  let assert Ok(tl) = zlist.tail(layer_sizes)
  zlist.zip(layer_sizes, tl)
  |> zlist.reduce(minigen.always(zlist.new()), fn(t, acc_gen) {
    let #(lr_sz, next_lr_sz) = t
    minigen.then(acc_gen, fn(acc_zls) {
      layer.generator(lr_sz, next_lr_sz)
      |> minigen.map(fn(layer) { zlist.cons(acc_zls, layer) })
    })
  })
  |> minigen.map(zlist.reverse)
}
