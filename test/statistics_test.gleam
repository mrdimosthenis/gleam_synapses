import gleam/iterator
import gleam/should
import gleam_synapses/statistics

pub fn root_mean_square_error_test() {
  [
    tuple([0.0, 0.0, 1.0], [0.0, 0.0, 1.0]),
    tuple([0.0, 0.0, 1.0], [0.0, 1.0, 1.0]),
  ]
  |> iterator.from_list
  |> statistics.root_mean_square_error
  |> should.equal(0.7071067811865476)
}
