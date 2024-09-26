//// Measure the difference between the values predicted by a neural network and the observed values.

import gleam/iterator.{type Iterator}
import gleam_zlists as zlist
import gleam_synapses/model/mathematics

/// The standard deviation of the prediction errors (root mean square error).
/// `output_pairs` should be an iterator o tuples that contain the expected and predicted values.
///
/// ```gleam
/// [#([0.0, 0.0, 1.0], [0.0, 0.0, 1.0]),
///  #([0.0, 0.0, 1.0], [0.0, 1.0, 1.0])]
/// |> iterator.from_list
/// |> stats.rmse
/// 0.7071067811865476
/// ```
///
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

/// The ratio of correct predictions to the total number of provided observations.
/// For a prediction to be considered as correct, the index of its maximum expected value
/// needs to be the same with the index of its maximum predicted value.
/// `output_pairs` should be an iterator o tuples that contain the expected and predicted values.
///
/// ```gleam
/// [
///   #([0.0, 0.0, 1.0], [0.0, 0.1, 0.9]),
///   #([0.0, 1.0, 0.0], [0.8, 0.2, 0.0]),
///   #([1.0, 0.0, 0.0], [0.7, 0.1, 0.2]),
///   #([1.0, 0.0, 0.0], [0.3, 0.3, 0.4]),
///   #([0.0, 0.0, 1.0], [0.2, 0.2, 0.6]),
/// ]
/// |> iterator.from_list
/// |> stats.score
/// 0.6
/// ```
///
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
