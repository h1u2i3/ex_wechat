defmodule ExWechat.Plugs.WechatMessageParser do
  @module_doc """
    Praser message from the body in conn, and then assign the message to conn.
    Then the developer can get the msg data (elixir data) with:

        message = conn.assigns[:message]

    This module doesn't have other function.
  """

  import Plug.Conn
  import ExWechat.Message

  def init(options) do
    options
  end

  def call(conn, _opts) do
    {:ok, body, conn} = read_body(conn)
    message = parser_message(body)
    assign(conn, :message, message)
  end
end
