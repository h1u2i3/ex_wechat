defmodule Wechat.Plugs.WechatMessageParser do
  @moduledoc """
    Praser message from the body in conn, and then assign the message to conn.
    Then the developer can get the msg data (elixir map) with:

        message = conn.assigns[:message]

    This module doesn't have other function.
  """

  import Plug.Conn
  import Wechat.Message.XmlMessage
  import Wechat.AesHelper

  def init(options) do
    options
  end

  def call(%Plug.Conn{params: params} = conn, options) do
    case conn.method do
      "POST" ->
        api = options[:api] || Wechat
        {:ok, body, conn} = read_body(conn)
        message = parse(body)
        # add aes message decode
        if Map.get(params, "msg_encrypt", nil) == "aes" do
          case decrypt(api, message.encrypt) do
            {:ok, result} ->
              assign(conn, :message, parse(result.message))

            {:error, _reason} ->
              assign(conn, :message, message)
          end
        else
          assign(conn, :message, message)
        end

      _ ->
        conn
    end
  end

  # def call(conn, _opts) do
  #   case conn.method do
  #     "POST" ->
  #       {:ok, body, conn} = read_body(conn)
  #       message = parse(body)
  #       assign(conn, :message, message)
  #     _      ->
  #       conn
  #   end
  # end
end
