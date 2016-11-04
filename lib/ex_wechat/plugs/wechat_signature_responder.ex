defmodule ExWechat.Plugs.WechatSignatureResponder do
  import Plug.Conn
  import ExWechat.Responder, only: [wechat_verify_responder: 1]

  def init(options) do
    options
  end

  def call(conn = %Plug.Conn{params: params}, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, wechat_verify_responder(params))
  end
end
