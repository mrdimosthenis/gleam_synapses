import gleam/iterator.{Iterator}
import gleam_zlists as zlist
import gleam_synapses/model/mathematics

pub fn root_mean_square_error(
  expected_values_with_output_values: Iterator(#(List(Float), List(Float))),
) -> Float {
  expected_values_with_output_values
  |> zlist.of_iterator
  |> zlist.map(fn(t) {
    let #(y_hat, y) = t
    let y_hat_zls = zlist.of_list(y_hat)
    let y_zls = zlist.of_list(y)
    #(y_hat_zls, y_zls)
  })
  |> mathematics.root_mean_square_error
}
