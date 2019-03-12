defmodule Wechat.Helpers.CryptoHelper do
  @moduledoc """
  Generate sha1 hash and verify sha1 with given string.
  """

  @doc """
  Check the sha hash of `string` with `signature`.
  """
  def wechat_hash_equal?(params, signature) do
    wechat_sha(params) == signature
  end

  @doc """
  Wechat sha hash
  """
  def wechat_sha(params) when is_map(params) do
    params
    |> Enum.sort()
    |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)
    |> Enum.join("&")
    |> sha1_hash
  end

  def wechat_sha(params) when is_list(params) do
    params
    |> Enum.sort()
    |> Enum.join()
    |> sha1_hash
  end

  def generate_nonce_str do
    23
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
    |> binary_part(0, 32)
    |> String.replace(~r/[=\/]/, "")
  end

  defp sha1_hash(string) do
    :sha
    |> :crypto.hash(string)
    |> Base.encode16()
    |> String.downcase()
  end
end
