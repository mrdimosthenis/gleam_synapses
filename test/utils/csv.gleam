import gleam/string
import gleam/list
import gleam/iterator.{Iterator}
import gleam/map.{Map}

fn lines(s: String) -> List(String) {
  string.split(s, "\n")
}

fn cells(s: String) -> List(String) {
  string.split(s, ",")
}

fn hmap(headers: List(String), line: String) -> Map(String, String) {
  let values = cells(line)
  list.zip(headers, values)
  |> map.from_list
}

pub fn iterator_of_hmaps(s: String) -> Iterator(Map(String, String)) {
  let #([first_line], rest_lines) =
    s
    |> lines
    |> list.split(1)
  let headers = cells(first_line)
  rest_lines
  |> list.map(fn(line) { hmap(headers, line) })
  |> iterator.from_list
}
