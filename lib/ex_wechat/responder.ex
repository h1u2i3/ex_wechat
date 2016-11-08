defmodule ExWechat.Responder do
  @moduledoc """
    `ExWechat.Responder` is to make respond to wechat server.
    It can be used with server verify and other things.
    This module will automaticlly generate needed methods for your Phoenix controller.

    For simple use:

        defmodule Demo.WechatController do
          use ExWechat.Responder    # interact with user, return message to user
          import ExWechat.Message   # function that parse and render wechat message
        end

    More complex example(when receives text message from user, it will return a text message with reverse text):

        defmodule Wechat.WechatController do
          require Logger

          use Wechat.Web, :controller
          use ExWechat.Responder

          import ExWechat.Message

          defp on_text_responder(conn) do
            message = conn.assigns[:message]
            case message do
              %{content: content} ->
                reply_with(conn, build_message(%{
                    msgtype: "text",
                    from: message.tousername,
                    to: message.fromusername,
                    content: String.reverse(content)
                  }))
              _   ->
                conn
            end
          end
        end

    There are several methods you can override:

        defp on_text_responder(conn),         do: conn
        defp on_image_responder(conn),        do: conn
        defp on_voice_responder(conn),        do: conn
        defp on_video_responder(conn),        do: conn
        defp on_shortvideo_responder(conn),   do: conn
        defp on_location_responder(conn),     do: conn
        defp on_link_responder(conn),         do: conn
        defp on_event_responder(conn),        do: conn

    these methods must return a `Plug.Conn`, just choose what you need.
  """

  use ExWechat.Base # import token from ExWechat.Base
  import ExWechat.Helpers.CryptoHelper

  @doc """
    check the signature with wechat server.
  """
  def wechat_verify_responder(%{"signature" => signature, "timestamp" => timestamp,
          "nonce" => nonce}) do
    check_signature(signature, timestamp, nonce)
  end

  defp check_signature(signature, timestamp, nonce) do
    [token, timestamp, nonce]
    |> Enum.sort
    |> Enum.join
    |> sha1_equal?(signature)
  end

  defmacro __using__(_opts) do
    quote do
      if !Code.ensure_loaded?(Plug.Conn) do
        import Plug.Conn
      end

      if !Code.ensure_loaded?(Phoenix.Controller) do
        import Phoenix.Controller
      end

      defp on_text_responder(conn),         do: conn
      defp on_image_responder(conn),        do: conn
      defp on_voice_responder(conn),        do: conn
      defp on_video_responder(conn),        do: conn
      defp on_shortvideo_responder(conn),   do: conn
      defp on_location_responder(conn),     do: conn
      defp on_link_responder(conn),         do: conn
      defp on_event_responder(conn),        do: conn

      def message_responder(conn) do
        message = conn.assigns[:message]
        reply_conn = case message do
          %{msgtype: "text"} ->
            on_text_responder(conn)
          %{msgtype: "voice"} ->
            on_voice_responder(conn)
          %{msgtype: "video"} ->
            on_video_responder(conn)
          %{msgtype: "image"} ->
            on_image_responder(conn)
          %{msgtype: "location"} ->
            on_location_responder(conn)
          %{msgtype: "shortvideo"} ->
            on_shortvideo_responder(conn)
          %{msgtype: "link"} ->
            on_link_responder(conn)
          %{msgtype: "event"} ->
            on_event_responder(conn)
          _ ->
            conn
        end
        case reply_conn do
          %Plug.Conn{}  ->
            conn = reply_conn
            if conn.assigns[:reply] do
              text conn, conn.assigns[:reply]
            else
              text conn, "success"
            end
          _             ->
            Logger.error "When use your own on_*_responder function, you should return a Plug.Conn"
            text conn, "success"
        end
      end

      def reply_with(conn, message) do
        assign conn, :reply, message
      end

      def signature_responder(conn) do
        case conn.assigns[:signature] do
          true  -> text(conn, conn.params["echostr"] )
          false -> halt(conn)
        end
      end

      def index(conn, _) do
        signature_responder(conn)
      end

      def show(conn, _) do
        signature_responder(conn)
      end

      def create(conn, _) do
        message_responder(conn)
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end
