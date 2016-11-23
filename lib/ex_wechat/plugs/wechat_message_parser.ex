defmodule ExWechat.Plugs.WechatMessageParser do
  @moduledoc """
    Praser message from the body in conn, and then assign the message to conn.
    Then the developer can get the msg data (elixir map) with:

        message = conn.assigns[:message]

    This module doesn't have other function.
  """

  import Plug.Conn
  import ExWechat.Message.XmlMessage

  def init(options) do
    options
  end

  def call(conn, _opts) do
    case conn.method do
      "POST" ->
        {:ok, body, conn} = read_body(conn)
        message = parse_message(body)
        assign(conn, :message, message)
      _      ->
        conn
    end
  end
end
