defmodule ExWechat.Helpers.XmlParser do
  @moduledoc """
    Parse xml string to elixir map.
  """

  @doc """
    Parse xml string to elixir map.
  """
  def parse_xml(xml, result \\ %{})

  def parse_xml([], result), do: result

  def parse_xml(xml, result) when is_binary(xml) do
    Floki.find(xml, "xml")
    |> parse_xml(result)
  end

  def parse_xml([{"xml", [], attrs}], result) do
    parse_xml(attrs, result)
  end

  def parse_xml([{key, _, [value]} | tail], result) when is_binary(value) do
    result = Map.put(result, String.to_atom(key), value)
    parse_xml(tail, result)
  end

  def parse_xml([{node, [], [{_, [], _} | _tail] = attrs}], result) when is_list(attrs) do
    Map.put(result, String.to_atom(node), parse_xml(attrs, %{}))
  end

  def parse_xml([{node, [], _attrs} | _tail] = attrs, result) when is_list(attrs) do
    key = String.to_atom(node)
    value = Enum.map(attrs, fn(attr)-> parse_xml(attr, %{}) end)
    Map.put(result, key, value)
  end

  def parse_xml({_node, [], attrs}, result) do
    parse_xml(attrs, result)
  end
end
