defmodule ExWechat.Helpers.XmlParser do
  @moduledoc """
    Parse xml string to elixir map.
  """

  @doc """
    Parse xml string to elixir map.
  """
  def parse_xml(xml, result \\ %{})
  def parse_xml(xml, result) when is_binary(xml),     do: xml   |> Floki.find("xml") |> parse_xml(result)
  def parse_xml([{"xml", [], attrs}], result),        do: attrs |> parse_xml(result)
  def parse_xml([ {key, _, [value]} | tail], result), do: tail  |> parse_xml(result |> Map.put(String.to_atom(key), value))
  def parse_xml([], result),                          do: result
end
