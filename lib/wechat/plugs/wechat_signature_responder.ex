defmodule Wechat.Plugs.WechatSignatureResponder do
  @moduledoc """
  Wechat server signature checker.
  Makesure the message is come from wechat server.
  http://mp.weixin.qq.com/wiki/8/f9a0b8382e0b77d87b3bcc1ce6fbc104.html
  """

  import Plug.Conn
  import Wechat.Helpers.CryptoHelper

  def init(options) do
    options
  end

  def call(%Plug.Conn{params: params} = conn, options) do
    api = options[:api] || Wechat
    case params do
      %{"signature" => _, "timestamp" => _, "nonce" => _} ->
        assign(conn, :signature, verify(api, params))
      _ ->
        assign(conn, :signature, false)
    end
  end

  defp verify(api, %{"signature" => signature,
        "timestamp" => timestamp, "nonce" => nonce}) do
    wechat_hash_equal?([token(api), timestamp, nonce], signature)
  end

  defp token(api) do
    apply(api, :token, [])
  end
end
