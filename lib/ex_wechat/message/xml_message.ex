defmodule ExWechat.Message.XmlMessage do
  @moduledoc """
  Module to deal with xml message.
  """

  import ExWechat.Helpers.XmlParser
  import ExWechat.Helpers.XmlRender
  import ExWechat.Helpers.TimeHelper

  alias ExWechat.Message.XmlMessage.Text
  alias ExWechat.Message.XmlMessage.Image
  alias ExWechat.Message.XmlMessage.Voice
  alias ExWechat.Message.XmlMessage.Video
  alias ExWechat.Message.XmlMessage.Music
  alias ExWechat.Message.XmlMessage.News

  @doc """
    Generate message for wechat.
    You can find what you need for generate message from the template file.

        build(fromusername: "userid", tousername: "server_app_id",
          msgtype: "text", content: "Hello World!"})

    will generate:

        <xml>
        <ToUserName><![CDATA[userid]]></ToUserName>
        <FromUserName><![CDATA[server_app_id]]></FromUserName>
        <CreateTime>1478449547</CreateTime>
        <MsgType><![CDATA[text]]></MsgType>
        <Content><![CDATA[Hello World!]]></Content> </xml>

    This method will automaticlly check the `msgtype`,
    and choose the right template to render message.
  """
  def build(message) do
    msgtype = message[:msgtype] || "text"
    module = Module.concat [ExWechat, Message, XmlMessage,
                            msgtype |> Macro.camelize]

    module
    |> struct(message)
    |> module.to_map
    |> render_xml
  end

  @doc """
    Get xml data from `Plug.Conn` ant then parse xml wechat message to Map.
    You can get this message by use:

        conn.assigns[:message]
  """
  def parse(xml_msg) do
    parse_xml(xml_msg)
  end


  defmodule Text do
    defstruct tousername: nil, fromusername: nil,
      createtime: nil, msgtype: "text", content: nil

    def to_map(struct) do
      struct
      |> Map.delete(:__struct__)
      |> Map.put(:createtime, current_unix_time)
    end
  end

  defmodule Image do
    defstruct tousername: nil, fromusername: nil,
      createtime: nil, msgtype: "image", mediaid: nil

    def to_map(struct) do
      struct
      |> Map.delete(:__struct__)
      |> Map.take([:tousername, :fromusername, :msgtype])
      |> Map.put(:createtime, current_unix_time)
      |> Map.put(:image, Map.take(struct, [:mediaid]))
    end
  end

  defmodule Video do
    defstruct tousername: nil, fromusername: nil,
      createtime: nil, msgtype: "video", title: nil, mediaid: nil,
      description: nil

    def to_map(struct) do
      struct
      |> Map.delete(:__struct__)
      |> Map.take([:tousername, :fromusername, :msgtype])
      |> Map.put(:createtime, current_unix_time)
      |> Map.put(:video, Map.take(struct, ~w/title mediaid description/a))
    end
  end

  defmodule Voice do
    defstruct tousername: nil, fromusername: nil,
      createtime: nil, msgtype: "voice", title: nil, mediaid: nil,
      description: nil

    def to_map(struct) do
      struct
      |> Map.delete(:__struct__)
      |> Map.take([:tousername, :fromusername, :msgtype])
      |> Map.put(:createtime, current_unix_time)
      |> Map.put(:voice, Map.take(struct, ~w/title mediaid description/a))
    end
  end

  defmodule Music do
    defstruct tousername: nil, fromusername: nil,
      createtime: nil, msgtype: "music", title: nil, description: nil,
      musicurl: nil, hqmusicurl: nil, thumbmediaid: nil

    def to_map(struct) do
      struct
      |> Map.delete(:__struct__)
      |> Map.take([:tousername, :fromusername, :msgtype])
      |> Map.put(:createtime, current_unix_time)
      |> Map.put(:music, Map.take(struct,
                ~w/title description musicurl hqmusicurl thumbmediaid/a))
    end
  end

  defmodule News do
    alias ExWechat.Message.XmlMessage.New

    defstruct tousername: nil, fromusername: nil,
      createtime: nil, msgtype: "news", articlecount: nil,
      articles: []

    def to_map(struct) do
      struct
      |> Map.delete(:__struct__)
      |> Map.take([:tousername, :fromusername, :msgtype])
      |> Map.put(:createtime, current_unix_time)
      |> Map.put(:articlecount, length(struct.articles))
      |> Map.put(:articles, struct.articles |> Enum.map(&New.to_map/1))
    end
  end

  defmodule New do
    defstruct title: nil, description: nil, picurl: nil, url: nil

    def to_map(struct) do
      struct |> Map.delete(:__struct__)
    end
  end
end
