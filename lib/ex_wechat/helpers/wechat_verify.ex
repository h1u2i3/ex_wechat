defmodule ExWechat.Helpers.WechatVerify do
  import ExWechat.Helpers.CryptoHelper

  @doc """
    check the signature with wechat server.
  """
  def verify(api, %{"signature" => signature,
        "timestamp" => timestamp, "nonce" => nonce}) do
    wechat_hash_equal?([token(api), timestamp, nonce], signature)
  end

  defp token(api) do
    apply(api, :token, [])
  end
end
