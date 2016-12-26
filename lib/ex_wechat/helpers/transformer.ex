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
        result = Map.put result, key, keyword_to_map(value, %{})
        keyword_to_map(tail, result)
      false ->
        added  = Enum.map value, &(keyword_to_map(&1, %{}))
        result = Map.put result, key, added
        keyword_to_map(tail, result)
    end
  end

  def keyword_to_map([{key, value} | tail], result) do
    result = Map.put result, key, value
    keyword_to_map(tail, result)
  end
end
