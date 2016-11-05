defmodule ExWechat.Responder do
  @module_doc """
    `ExWechat.Responder` is for make respond to wechat server.
    can be used with server verify and other things.
    or you can use it to import the reponder for uses's message responder.

        use ExWechat.Responder

    eg: use in the controller.

        defmodule ResponderController do
          use ExWechat.Responder
        end

    you can wirte your own responder method.

        def on_text_responder(conn),         do: conn
        def on_image_responder(conn),        do: conn
        def on_voice_responder(conn),        do: conn
        def on_video_responder(conn),        do: conn
        def on_shortvideo_responder(conn),   do: conn
        def on_location_responder(conn),     do: conn
        def on_link_responder(conn),         do: conn
        def on_event_responder(conn),        do: conn

    message will be treat as custom message in default.
  """

  use ExWechat.Base # import token from ExWechat.Base
  import ExWechat.Utils.Crypto

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
        conn = case message do
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
        if conn.assigns[:reply] do
          text conn, conn.assigns[:reply]
        else
          text conn, "success"
        end
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

      def create(conn, _) do
        message_responder(conn)
      end

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end
