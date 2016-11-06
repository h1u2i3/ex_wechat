defmodule ExWechat.Message do
  @moduledoc """
    Parse wechat message from `Plug.Conn`, generate wechat message.
  """

  @text         "text.eex"
  @voice        "voice.eex"
  @video        "video.eex"
  @image        "image.eex"
  @news         "news.eex"
  @music        "music.eex"

  @doc """
    Generate message for wechat.
    `msg` is a `Map` struct.
    You can find what you need for generate message from the template file.

        build_message(%{
          from: "userid",
          to: "server_app_id",
          msgtype: "text",
          content: "Hello World!"
        })

    will generate:

        <xml>
        <ToUserName><![CDATA[userid]]></ToUserName>
        <FromUserName><![CDATA[server_app_id]]></FromUserName>
        <CreateTime>1478449547</CreateTime>
        <MsgType><![CDATA[text]]></MsgType>
        <Content><![CDATA[Hello World!]]></Content>
        </xml>

    This method will automatic check the `msgtype`, and choose the right template to render message.
  """
  def build_message(msg) do
    render_message(msg)
  end

  @doc """
    Parser xml wechat message to Map.
    Get xml data from `Plug.Conn`:

      <xml>
      <ToUserName><![CDATA[userid]]></ToUserName>
      <FromUserName><![CDATA[server_app_id]]></FromUserName>
      <CreateTime>1478449547</CreateTime>
      <MsgType><![CDATA[text]]></MsgType>
      <Content><![CDATA[Hello World!]]></Content>
      </xml>

    and then will convert this xml data to Map.
    You can get this Map by:

        conn.assigns[:message]
  """
  def parser_message(xml_msg) do
    [{"xml", [], attrs}] = Floki.find(xml_msg, "xml")
    for {key, _, [value]} <- attrs, into: %{} do
      {String.to_atom(key), value}
    end
  end

  defp render_message(msg = %{msgtype: "text"}),       do: render(@text,       msg)
  defp render_message(msg = %{msgtype: "video"}),      do: render(@video,      msg)
  defp render_message(msg = %{msgtype: "music"}),      do: render(@music,      msg)
  defp render_message(msg = %{msgtype: "voice"}),      do: render(@voice,      msg)
  defp render_message(msg = %{msgtype: "image"}),      do: render(@image,      msg)
  defp render_message(msg = %{msgtype: "news"}),       do: render(@news,       msg)

  defp render(file, msg) do
    EEx.eval_file Path.join([__DIR__, "templates", file]), assigns: Enum.map(msg, fn ({key, value}) -> {key, value} end)
  end
end
