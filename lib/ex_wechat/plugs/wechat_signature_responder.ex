defmodule ExWechat.Plugs.WechatSignatureResponder do
  @moduledoc """
    Wechat server signature checker.
    Makesure the message is come from wechat server.
    http://mp.weixin.qq.com/wiki/8/f9a0b8382e0b77d87b3bcc1ce6fbc104.html
  """

  import Plug.Conn
  import ExWechat.Responder, only: [wechat_verify_responder: 1]

  def init(options) do
    options
  end

  def call(conn = %Plug.Conn{params: params}, _opts) do
    case params do
      %{"signature" => _, "timestamp" => _, "nonce" => _} ->
        assign(conn, :signature, wechat_verify_responder(params))
      _ ->
        assign(conn, :signature, false)
    end
  end
end
