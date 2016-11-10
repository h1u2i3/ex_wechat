defmodule ExWechat.Helpers.ParamsParser do

  @doc false
  def do_parse_params(params), do: _do_parse_params([], "", "", params)

  defp _do_parse_params(result, key, value, params)
  defp _do_parse_params(result, "", "", ""),               do: result
  defp _do_parse_params(result, key, value, ""),           do: _do_parse_params(result, key, value, ", ")
  defp _do_parse_params(result, key, value, "=" <> rest),  do: result |> put_to_result(key, value) |> _do_parse_params(key, value, rest)
  defp _do_parse_params(result, key, "", ", " <> rest),    do: result |> put_to_result(key, get_attr(key)) |> _do_parse_params("", "", rest)
  defp _do_parse_params(result, key, value, ", " <> rest), do: result |> put_to_result(key, value) |> _do_parse_params("", "", rest)
  defp _do_parse_params(result, key, value, <<binary::8>> <> rest), do: result |> check_key(key) |> decide_add_key_or_value(result, binary, key, value, rest)

  defp decide_add_key_or_value(boolean, result, binary, key, value, rest)
  defp decide_add_key_or_value(true, result, binary, key, value, rest),    do: _do_parse_params(result, key, value <> b_to_string(binary), rest)
  defp decide_add_key_or_value(false, result, binary, key, _value, rest),  do: _do_parse_params(result, key <> b_to_string(binary), "", rest)

  defp check_key(result, key), do: Keyword.has_key?(result, String.to_atom(key))
  defp put_to_result(result, key, value), do: result |> Keyword.put(key |> String.to_atom, value)
  defp get_attr(key), do: apply(ExWechat.Api, key |> String.to_atom, [])
  defp b_to_string(binary), do: IO.chardata_to_string([binary])
end
