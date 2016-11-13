defmodule ExWechat.Message do
  @moduledoc """
    Parse wechat message from `Plug.Conn` && Generate wechat message from `Map`.
  """
  import ExWechat.Helpers.XmlParser
  import ExWechat.Helpers.XmlRender

  @text         "text.eex"
  @voice        "voice.eex"
  @video        "video.eex"
  @image        "image.eex"
  @news         "news.eex"
  @music        "music.eex"

  @doc """
    Generate message for wechat.
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

    This method will automaticlly check the `msgtype`,
    and choose the right template to render message.
  """
  def build_message(msg), do: render_message(msg)

  @doc """
    Get xml data from `Plug.Conn` ant then parse xml wechat message to Map.
    You can get this message by use:

        conn.assigns[:message]
  """
  def parse_message(xml_msg), do: parse_xml(xml_msg)

  defp render_message(msg = %{msgtype: "text"}) do
    render_xml(template_path(@text),  msg)
  end
  defp render_message(msg = %{msgtype: "video"}) do
    render_xml(template_path(@video), msg)
  end
  defp render_message(msg = %{msgtype: "music"}) do
    render_xml(template_path(@music), msg)
  end
  defp render_message(msg = %{msgtype: "voice"}) do
    render_xml(template_path(@voice), msg)
  end
  defp render_message(msg = %{msgtype: "image"}) do
    render_xml(template_path(@image), msg)
  end
  defp render_message(msg = %{msgtype: "news"}) do
    render_xml(template_path(@news),  msg)
  end

  defp template_path(file) do
    Path.join([__DIR__, "templates", file])
  end
end
