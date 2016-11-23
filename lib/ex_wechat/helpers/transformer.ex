defmodule ExWechat.Helpers.Transformer do
  @moduledoc """
    Data tranform.
  """

  @doc """
    Transform from keyword to map.
  """
  def keyword_to_map(keyword, result \\ %{})

  def keyword_to_map([], result), do: result

  def keyword_to_map([{key, value} | tail], result) when is_list(value) do
    case Keyword.keyword?(value) do
      true  ->
        result = result
                 |> Map.put(key, keyword_to_map(value, %{}))

        keyword_to_map(tail, result)
      false ->
        added = value
                |> Enum.map(fn(item) ->
                     keyword_to_map(item, %{})
                   end)

        result = result
                 |> Map.put(key, added)

        keyword_to_map(tail, result)
    end
  end

  def keyword_to_map([{key, value} | tail], result) when is_map(value) do
    result = result
             |> Map.put(key, value)
    keyword_to_map(tail, result)
  end

  def keyword_to_map([{key, value} | tail], result) when is_binary(value) do
    result = result
             |> Map.put(key, value)
    keyword_to_map(tail, result)
  end

  def keyword_to_map([{key, value} | tail], result) when is_atom(value) do
    result = result
             |> Map.put(key, value)
    keyword_to_map(tail, result)
  end
end
