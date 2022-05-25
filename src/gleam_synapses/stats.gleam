import gleam/iterator.{Iterator}
import gleam_zlists as zlist
import gleam_synapses/model/mathematics

pub fn rmse(output_pairs: Iterator(#(List(Float), List(Float)))) -> Float {
  output_pairs
  |> iterator.map(fn(t) {
    let #(y_hat, y) = t
    let y_hat_zls = zlist.of_list(y_hat)
    let y_zls = zlist.of_list(y)
    #(y_hat_zls, y_zls)
  })
  |> mathematics.root_mean_square_error
}

pub fn score(output_pairs: Iterator(#(List(Float), List(Float)))) -> Float {
  output_pairs
  |> iterator.map(fn(t) {
    let #(y_hat, y) = t
    let y_hat_zls = zlist.of_list(y_hat)
    let y_zls = zlist.of_list(y)
    #(y_hat_zls, y_zls)
  })
  |> mathematics.accuracy
}
