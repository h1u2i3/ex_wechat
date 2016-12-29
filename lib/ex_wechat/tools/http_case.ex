defmodule ExWechat.Tools.HttpCase do
  @moduledoc """
  A module to make test with ExWechat.Http easy
  """
  @table :ex_wechat_http_case

  @doc """
  Set the value for the request, only useful in test envt
  """
  def set(url, params, value) do
    @table
    |> :ets.insert({url, Enum.sort(params), value})
  end

  @doc """
  Get the value for the request, only useful in test env
  """
  def get(url, params) do
    @table
    |> :ets.match({url, Enum.sort(params), :"$1"})
    |> List.flatten
    |> List.first
  end

  def clean() do
    :ets.delete_all_objects(@table)
  end
end
