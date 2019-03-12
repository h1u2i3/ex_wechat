defmodule Wechat.AesHelper do
  @moduledoc """
  Use to encode and decode for wechat message.
  """

  def encrypt(api \\ Wechat.Api, string) do
    key = aes_key(api)
    appid = appid(api)

    ivec = binary_part(key, 0, 16)
    paded_string = add_padding(string)
    len = String.length(paded_string)

    encode_string =
      <<ivec::binary-size(16), len::integer-size(32), string::binary-size(len), appid::binary>>

    {:ok, :crypto.block_encrypt(:aes_cbc128, key, ivec, encode_string)}
  end

  def decrypt(api \\ Wechat.Api, binary) do
    with key <- aes_key(api),
         appid <- appid(api),
         {:ok, string} <- binary |> Base.decode64!() |> decode_encode_text(key) |> remove_padding,
         {:ok, result} <- pattern_match_for_message(string, appid) do
      {:ok, result}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp pattern_match_for_message(string, appid) do
    <<_::binary-size(16), len::integer-size(32), message::binary-size(len), appid_decode::binary>> =
      string

    if appid == appid_decode do
      {:ok, %{appid: appid, message: message}}
    else
      {:error, "The decode appid is not the same"}
    end
  end

  defp aes_key(api) do
    aes = apply(api, :aes, [])
    Base.decode64!(aes <> "=")
  end

  defp appid(api) do
    apply(api, :appid, [])
  end

  defp decode_encode_text(string, key) do
    # IVec is an arbitrary initializing vector.
    ivec = binary_part(key, 0, 16)
    :crypto.block_decrypt(:aes_cbc128, key, ivec, string)
  end

  defp remove_padding(paded_string) do
    size = byte_size(paded_string)
    <<last::utf8>> = binary_part(paded_string, size, -1)

    if last >= 1 and last <= 32 do
      {:ok, binary_part(paded_string, 0, size - last)}
    else
      {:error, "Aes remove padding error, the padding content should between 1 and 32"}
    end
  end

  defp add_padding(string) do
    size = byte_size(string)
    size_rem_32 = rem(size, 32)

    add_length = if size_rem_32 == 0, do: 32, else: 32 - size_rem_32
    add_content = if size_rem_32 == 0, do: <<32>>, else: <<size_rem_32>>

    <<string::utf8>> <> String.duplicate(add_content, add_length)
  end
end
