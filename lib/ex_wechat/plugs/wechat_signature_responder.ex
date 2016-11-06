defmodule ExWechat.Plugs.WechatSignatureResponder do
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
