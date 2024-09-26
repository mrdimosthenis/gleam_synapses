import gleam/float
import gleam/int
import gleam/iterator.{type Iterator}
import gleam/pair
import gleam_zlists.{type ZList} as zlist

@external(erlang, "math", "exp")
pub fn exp(x: Float) -> Float

@external(erlang, "math", "log")
pub fn log(x: Float) -> Float

@external(erlang, "math", "tanh")
pub fn tanh(x: Float) -> Float

pub fn dot_product(left: ZList(Float), right: ZList(Float)) -> Float {
  zlist.zip(left, right)
  |> zlist.map(fn(x) {
    let #(a, b) = x
    a *. b
  })
  |> zlist.sum
}

fn euclidean_distance(xs: ZList(Float), ys: ZList(Float)) -> Float {
  let assert Ok(res) =
    xs
    |> zlist.zip(ys)
    |> zlist.map(fn(t) {
      let #(x, y) = t
      let diff = x -. y
      diff *. diff
    })
    |> zlist.sum
    |> float.square_root
  res
}

pub fn root_mean_square_error(
  y_hats_with_ys: Iterator(#(ZList(Float), ZList(Float))),
) -> Float {
  let #(n, s) =
    y_hats_with_ys
    |> iterator.map(fn(t) {
      let #(y_hat, y) = t
      let d = euclidean_distance(y_hat, y)
      d *. d
    })
    |> iterator.fold(#(0, 0.0), fn(acc, x) {
      let #(acc_n, acc_s) = acc
      #(acc_n + 1, acc_s +. x)
    })
  let avg = s /. int.to_float(n)
  let assert Ok(res) = float.square_root(avg)
  res
}

fn index_of_max_val(ys: ZList(Float)) -> Int {
  let assert Ok(#(hd, rst)) =
    zlist.indices()
    |> zlist.zip(ys)
    |> zlist.uncons
  zlist.reduce(rst, hd, fn(x, acc) {
    let #(_, v) = x
    let #(_, acc_v) = acc
    case v >. acc_v {
      True -> x
      False -> acc
    }
  })
  |> pair.first
}

pub fn accuracy(
  y_hats_with_ys: Iterator(#(ZList(Float), ZList(Float))),
) -> Float {
  let #(n, s) =
    y_hats_with_ys
    |> iterator.map(fn(t) {
      let #(y_hat, y) = t
      index_of_max_val(y_hat) == index_of_max_val(y)
    })
    |> iterator.fold(#(0, 0), fn(acc, x) {
      let #(acc_n, acc_s) = acc
      let new_s = case x {
        True -> acc_s + 1
        False -> acc_s
      }
      #(acc_n + 1, new_s)
    })
  int.to_float(s) /. int.to_float(n)
}
