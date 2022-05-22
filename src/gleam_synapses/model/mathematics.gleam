import gleam/float
import gleam/int
import gleam_zlists.{ZList} as zlist

pub external fn exp(x: Float) -> Float =
  "math" "exp"

pub external fn log(x: Float) -> Float =
  "math" "log"

pub external fn tanh(x: Float) -> Float =
  "math" "tanh"

pub fn dot_product(left: ZList(Float), right: ZList(Float)) -> Float {
  zlist.zip(left, right)
  |> zlist.map(fn(x) {
    let #(a, b) = x
    a *. b
  })
  |> zlist.sum
}

fn euclidean_distance(xs: ZList(Float), ys: ZList(Float)) -> Float {
  assert Ok(res) =
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
  y_hats_with_ys: ZList(#(ZList(Float), ZList(Float))),
) -> Float {
  let #(n, s) =
    y_hats_with_ys
    |> zlist.map(fn(t) {
      let #(y_hat, y) = t
      let d = euclidean_distance(y_hat, y)
      d *. d
    })
    |> zlist.reduce(
      #(0, 0.0),
      fn(x, acc) {
        let #(acc_n, acc_s) = acc
        #(acc_n + 1, acc_s +. x)
      },
    )
  let avg = s /. int.to_float(n)
  assert Ok(res) = float.square_root(avg)
  res
}
