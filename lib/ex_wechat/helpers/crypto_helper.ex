defmodule ExWechat.Helpers.CryptoHelper do
  @moduledoc """
    generate sha1 and verify sha1  of given string.
  """

  @doc """
    Check the sha hash of `string` with `signature`.
  """
  def sha1_equal?(string, signature) do
    sha1_hash(string) == signature
  end

  defp sha1_hash(string) do
    :crypto.hash(:sha, string) |> Base.encode16 |> String.downcase
  end
end
