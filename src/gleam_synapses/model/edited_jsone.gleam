//// This module is just an edited copy of gleam_json library 
////
//// For more information see [this website](https://github.com/rjdellecese/gleam_jsone).

import decode.{Decoder} as dynamic_decode
import gleam/atom as atom_mod
import gleam/dynamic.{Dynamic}
import gleam/string
import gleam/map
import gleam/pair
import gleam/list as list_mod

/// The option for determining whether to return the first or last key/value
/// when there exist duplicates.
pub type DuplicateMapKeys {
  First
  Last
}

// DECODING
/// The available decoding options. The descriptions below are lifted or
/// adapted from the [jsone docs](https://hexdocs.pm/jsone/).
///
///
/// ### `allow_ctrl_chars`
///
/// If the value is `True`, strings which contain unescaped control characters
/// will be regarded as a legal JSON string.
///
///
/// ### `reject_invalid_utf8`
///
/// Rejects JSON strings which contain invalid UTF-8 byte sequences.
///
///
/// ### `duplicate_map_keys`
///
/// [IETF RFC 4627](https://www.ietf.org/rfc/rfc4627.txt) says that keys SHOULD
/// be unique, but they don't have to be. Most JSON parsers will either give
/// you the value of the first, or last duplicate property encountered.
///
/// If the value of this option is `First`, the first duplicate key/value is
/// returned. If it is `Last`, the last is instead.
pub type Options {
  Options(
    allow_ctrl_chars: Bool,
    reject_invalid_utf8: Bool,
    duplicate_map_keys: DuplicateMapKeys,
  )
}

/// The default options used by the `decode` function. They are:
///
/// ```
/// Options(
///   allow_ctrl_chars: False,
///   reject_invalid_utf8: False,
///   duplicate_map_keys: First,
/// )
/// ```
pub fn default_options() -> Options {
  Options(
    allow_ctrl_chars: False,
    reject_invalid_utf8: False,
    duplicate_map_keys: First,
  )
}

/// Transforms the jsone options from Gleam into their proper Erlang format.
fn transform_options(options: Options) -> Dynamic {
  let Options(
    duplicate_map_keys: duplicate_map_keys,
    reject_invalid_utf8: reject_invalid_utf8,
    allow_ctrl_chars: allow_ctrl_chars,
  ) = options

  let duplicate_map_keys_dynamic =
    tuple(
      atom_mod.create_from_string("duplicate_map_keys"),
      case duplicate_map_keys {
        First -> atom_mod.create_from_string("first")
        Last -> atom_mod.create_from_string("last")
      },
    )
    |> dynamic.from

  let allow_ctrl_chars_dynamic =
    tuple(atom_mod.create_from_string("allow_ctrl_chars"), allow_ctrl_chars)
    |> dynamic.from

  let reject_invalid_utf8_dynamic =
    atom_mod.create_from_string("reject_invalid_utf8")
    |> dynamic.from

  let maybe_prepend_reject_invalid_utf8_dynamic = fn(options: List(Dynamic)) {
    case reject_invalid_utf8 {
      True -> [reject_invalid_utf8_dynamic, ..options]
      False -> options
    }
  }

  [duplicate_map_keys_dynamic, allow_ctrl_chars_dynamic]
  |> maybe_prepend_reject_invalid_utf8_dynamic
  |> dynamic.from
}

// PERFORM DECODING
external fn jsone_try_decode(String) -> Dynamic =
  "jsone" "try_decode"

external fn jsone_try_decode_with_options(String, Dynamic) -> Dynamic =
  "jsone" "try_decode"

fn jsone_try_decode_decoder() -> Decoder(Dynamic) {
  let ok_decoder = dynamic_decode.element(1, dynamic_decode.dynamic())
  let error_decoder = dynamic_decode.fail("Invalid JSON")

  dynamic_decode.ok_error_tuple(ok_decoder, error_decoder)
}

// Uses the `default_options`.
pub fn decode(json: String) -> Result(Dynamic, String) {
  json
  |> jsone_try_decode
  |> dynamic_decode.decode_dynamic(jsone_try_decode_decoder())
}

pub fn decode_with_options(
  json: String,
  options: Options,
) -> Result(Dynamic, String) {
  json
  |> jsone_try_decode_with_options(transform_options(options))
  |> dynamic_decode.decode_dynamic(jsone_try_decode_decoder())
}

// ENCODING
/// Represents a JSON value.
pub type JsonValue {
  JsonString(String)
  JsonNumber(JsonNumber)
  JsonArray(List(JsonValue))
  JsonBool(Bool)
  JsonNull
  JsonObject(List(tuple(String, JsonValue)))
}

/// A JSON number can be either an `Int` or a `Float`.
pub type JsonNumber {
  JsonInt(Int)
  JsonFloat(Float)
}

/// Create a JSON string.
pub fn string(string: String) -> JsonValue {
  JsonString(string)
}

/// Create a JSON int.
pub fn int(int: Int) -> JsonValue {
  JsonNumber(JsonInt(int))
}

/// Create a JSON float.
pub fn float(float: Float) -> JsonValue {
  JsonNumber(JsonFloat(float))
}

/// Create an array of JSON values.
pub fn array(list: List(a), encoder: fn(a) -> JsonValue) -> JsonValue {
  list
  |> list_mod.map(encoder)
  |> JsonArray
}

/// Create a JSON boolean value.
pub fn bool(bool: Bool) -> JsonValue {
  JsonBool(bool)
}

/// Create a JSON null value.
pub fn null() -> JsonValue {
  JsonNull
}

/// Create a JSON object.
pub fn object(object: List(tuple(String, JsonValue))) -> JsonValue {
  JsonObject(object)
}

pub fn to_dynamic(json_value: JsonValue) -> Dynamic {
  case json_value {
    JsonString(string) -> dynamic.from(string)
    JsonNumber(json_number) ->
      case json_number {
        JsonInt(int) -> dynamic.from(int)
        JsonFloat(float) -> dynamic.from(float)
      }
    JsonArray(list) ->
      list
      |> list_mod.map(to_dynamic)
      |> dynamic.from
    JsonNull ->
      "null"
      |> atom_mod.create_from_string
      |> dynamic.from
    JsonBool(bool) -> dynamic.from(bool)
    JsonObject(object) ->
      object
      |> list_mod.map(pair.map_second(_, to_dynamic))
      |> map.from_list
      |> dynamic.from
  }
}

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
  let ok_decoder = dynamic_decode.element(1, dynamic_decode.dynamic())
  let error_decoder = dynamic_decode.fail("Invalid JSON value")

  dynamic_decode.ok_error_tuple(ok_decoder, error_decoder)
}

pub fn encode(json_value: JsonValue) -> Result(Dynamic, String) {
  let encode_option = [FloatFormat([Decimals(18), Compact])]
  json_value
  |> to_dynamic
  |> jsone_try_encode(encode_option)
  |> dynamic_decode.decode_dynamic(jsone_try_decoder())
}
