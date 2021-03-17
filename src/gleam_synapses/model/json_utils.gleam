import gleam/dynamic.{Dynamic}
import decode.{Decoder}
import gleam/jsone.{JsonValue}

// TODO: get rid of this if/when a future version of gleam/jsone gives the option of formating
type Decimals {
  Decimals(Int)
  Compact
}

type FloatFormat {
  FloatFormat(List(Decimals))
}

type EncodeOption =
  List(FloatFormat)

external fn jsone_try_encode(Dynamic, EncodeOption) -> Dynamic =
  "jsone" "try_encode"

fn jsone_try_decoder() -> Decoder(Dynamic) {
  let ok_decoder = decode.element(1, decode.dynamic())
  let error_decoder = decode.fail("Invalid JSON value")

  decode.ok_error_tuple(ok_decoder, error_decoder)
}

pub fn encode(json_value: JsonValue) -> Result(Dynamic, String) {
  let encode_option = [FloatFormat([Decimals(18), Compact])]
  json_value
  |> jsone.to_dynamic
  |> jsone_try_encode(encode_option)
  |> decode.decode_dynamic(jsone_try_decoder())
}
