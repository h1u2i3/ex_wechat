defmodule ExWechat.Responder do
  @module_doc """
    `ExWechat.Responder` is for make respond to wechat server.
    can be used with server verify and other things.
    for verify signature:

        import ExWechat.Responder, only: [wechat_verify_responder: 1]

    or you can use it to import the reponder for uses's message responder.

        use ExWechat.Responder

    eg: use in the controller.

        defmodule ResponderController do
          use ExWechat.Responder
        end

    you can wirte your own responder method.

        defp on_text_responder(data),         do: data
        defp on_image_responder(data),        do: data
        defp on_voice_responder(data),        do: data
        defp on_video_responder(data),        do: data
        defp on_shortvideo_responder(data),   do: data
        defp on_location_responder(data),     do: data
        defp on_link_responder(data),         do: data
        defp on_event_responder(data),        do: data

    message will be treat as custom message in default.
  """

  use ExWechat.Base # import token from ExWechat.Base
  import ExWechat.Utils.Crypto

  @doc """
    check the signature with wechat server.
  """
  def wechat_verify_responder(%{"signature" => signature, "timestamp" => timestamp, 
          "nonce" => nonce, "echostr" => echostr}) do
    check_signature(signature, timestamp, nonce)
  end

  defp check_signature(signature, timestamp, nonce) do
    [token, timestamp, nonce]
    |> Enum.sort
    |> Enum.join
    |> sha1_equal?(signature)
  end

  defmacro __before_compile__(_env) do
    quote do
      def message_responder(data) do
        data
        |> on_text_responder
        |> on_image_responder
        |> on_voice_responder
        |> on_video_responder
        |> on_shortvideo_responder
        |> on_location_responder
        |> on_link_responder
        |> on_event_responder
      end

      defp on_text_responder(data),         do: data
      defp on_image_responder(data),        do: data
      defp on_voice_responder(data),        do: data
      defp on_video_responder(data),        do: data
      defp on_shortvideo_responder(data),   do: data
      defp on_location_responder(data),     do: data
      defp on_link_responder(data),         do: data
      defp on_event_responder(data),        do: data
    end
  end

  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)
    end
  end
end
