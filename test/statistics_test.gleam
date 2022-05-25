import gleam/iterator
import gleeunit/should
import gleam_synapses/stats

pub fn root_mean_square_error_test() {
  [#([0.0, 0.0, 1.0], [0.0, 0.0, 1.0]), #([0.0, 0.0, 1.0], [0.0, 1.0, 1.0])]
  |> iterator.from_list
  |> stats.rmse
  |> should.equal(0.7071067811865476)
}

pub fn accuracy_test() {
  [
    #([0.0, 0.0, 1.0], [0.0, 0.1, 0.9]),
    #([0.0, 1.0, 0.0], [0.8, 0.2, 0.0]),
    #([1.0, 0.0, 0.0], [0.7, 0.1, 0.2]),
    #([1.0, 0.0, 0.0], [0.3, 0.3, 0.4]),
    #([0.0, 0.0, 1.0], [0.2, 0.2, 0.6]),
  ]
  |> iterator.from_list
  |> stats.score
  |> should.equal(0.6)
}
