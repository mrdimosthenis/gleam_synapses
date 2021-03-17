import gleam/pair

external type OkOrError

external type File

external fn read_file(String) -> tuple(OkOrError, File) =
  "file" "read_file"

external fn characters_to_list(File) -> String =
  "unicode" "characters_to_list"

pub fn read(path: String) -> String {
  path
  |> read_file
  |> pair.second
  |> characters_to_list
}
