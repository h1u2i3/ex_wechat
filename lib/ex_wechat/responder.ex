defmodule ExWechat.Responder do
  @moduledoc """
    `ExWechat.Responder` is to make respond to wechat server.
    It can be used with server verify and other things.
    This module will automaticlly generate needed
    methods for your Phoenix controller.

    For simple use:

        defmodule Demo.WechatController do
          # interact with user, return message to user
          use ExWechat.Responder

           # function that parse and render wechat message
          import ExWechat.Message
        end

    More complex example(when receives text message from user,
    it will return a text message with reverse text):

        defmodule Wechat.CustomerWechatController do
          use Wechat.Web, :controller
          use ExWechat.Responder

          import ExWechat.Message

          defp on_text_responder(conn) do
            message = conn.assigns[:message]
            case message do
              %{content: "我要图"} ->
                reply_with(conn, generate_passive(message, msgtype: "news",
                  articles: [
                    %{ title: "sjsjssjsj", description: "xxxxlaldsaldskl",
                       picurl: "picurl", url: "http://baidu.com" },
                    %{ title: "sjsjssjsj", description: "xxxxlaldsaldskl",
                       picurl: "picurl", url: "http://baidu.com" }
                    ]))
              %{content: content} ->
                reply_with(conn, generate_passive(message, msgtype: "text",
                   content: String.reverse(content)))
              _ ->
                conn
            end
          end
        end

    There are several methods you can override:

        def on_text_responder(conn),         do: conn
        def on_image_responder(conn),        do: conn
        def on_voice_responder(conn),        do: conn
        def on_video_responder(conn),        do: conn
        def on_shortvideo_responder(conn),   do: conn
        def on_location_responder(conn),     do: conn
        def on_link_responder(conn),         do: conn
        def on_event_responder(conn),        do: conn

    these methods must return a `Plug.Conn`,
    just choose what you need.
  """

  defmacro __using__(_opts) do
    quote do
      unless Code.ensure_loaded?(Plug.Conn) do
        import Plug.Conn
      end

      unless Code.ensure_loaded?(Phoenix.Controller) do
        import Phoenix.Controller
      end

      def on_text_responder(conn),         do: conn
      def on_image_responder(conn),        do: conn
      def on_voice_responder(conn),        do: conn
      def on_video_responder(conn),        do: conn
      def on_shortvideo_responder(conn),   do: conn
      def on_location_responder(conn),     do: conn
      def on_link_responder(conn),         do: conn
      def on_event_responder(conn),        do: conn

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
            case reply_conn.assigns[:signature] do
              true ->
                if reply_conn.assigns[:reply] do
                  text reply_conn, conn.assigns[:reply]
                else
                  text reply_conn, "success"
                end

              false ->
                text reply_conn, "forbidden"
            end

          _             ->
            text conn, "success"
        end
      end

      def reply_with(conn, message) do
        assign conn, :reply, message
      end

      def signature_responder(conn) do
        case conn.assigns[:signature] do
          true  -> text(conn, conn.params["echostr"] )
          false -> text(conn, "forbidden")
        end
      end

      def index(conn, _),  do: signature_responder(conn)
      def show(conn, _),   do: signature_responder(conn)
      def create(conn, _), do: message_responder(conn)

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end
