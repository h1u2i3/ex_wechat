defmodule Wechat.Responder do
  @moduledoc """
    `Wechat.Responder` is to make respond to wechat server.
    It can be used with server verify and other things.
    This module will automaticlly generate needed
    methods for your Phoenix controller.

    For simple use:

        defmodule Demo.WechatController do
          # interact with user, return message to user
          use Wechat.Responder

           # function that parse and render wechat message
          import Wechat.Message
        end

    More complex example(when receives text message from user,
    it will return a text message with reverse text):

        defmodule Wechat.CustomerWechatController do
          use Wechat.Web, :controller
          use Wechat.Responder

          import Wechat.Message

          defp on_text_responder(conn) do
            message = conn.assigns[:message]
            case message do
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
        def transfer_customer_service(conn), do: conn

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

      def transfer_customer_service(conn) do
        message = conn.assigns[:message]
        content = """
        <xml>
        <ToUserName><![CDATA[#{Map.get(message, :fromusername)}]]></ToUserName>
        <FromUserName><![CDATA[#{Map.get(message, :tousername)}]]></FromUserName>
        <CreateTime>#{:os.system_time(:second)}</CreateTime>
        <MsgType><![CDATA[transfer_customer_service]]></MsgType>
        </xml>
        """
        send_xml conn, content
      end

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
                  send_xml reply_conn, reply_conn.assigns[:reply]
                else
                  text conn, "success"
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

      defp send_xml(conn, content) do
        conn
        |> put_resp_header("content-type", "application/xml; encoding=utf-8")
        |> send_resp(200, content)
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end
