defmodule Wechat.Message.XmlMessage do
  @moduledoc """
  Module to deal with xml message.
  """

  import Wechat.Helpers.XmlParser
  import Wechat.Helpers.XmlRender

  alias Wechat.Helpers.TimeHelper
  alias Wechat.Message.XmlMessage.Text
  alias Wechat.Message.XmlMessage.Image
  alias Wechat.Message.XmlMessage.Voice
  alias Wechat.Message.XmlMessage.Video
  alias Wechat.Message.XmlMessage.Music
  alias Wechat.Message.XmlMessage.News

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
  def build(message, time \\ &TimeHelper.current_unix_time/0) do
    msgtype = message[:msgtype] || "text"
    module = Module.concat([Wechat, Message, XmlMessage, msgtype |> Macro.camelize()])

    message =
      Enum.into(message, %{})
      |> Map.put(:createtime, time.())

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
    @moduledoc false
    defstruct tousername: nil, fromusername: nil, createtime: nil, msgtype: "text", content: nil

    def to_map(struct) do
      struct
      |> Map.delete(:__struct__)
    end
  end

  defmodule Image do
    @moduledoc false
    defstruct tousername: nil, fromusername: nil, createtime: nil, msgtype: "image", mediaid: nil

    def to_map(struct) do
      struct
      |> Map.delete(:__struct__)
      |> Map.take([:tousername, :fromusername, :msgtype, :createtime])
      |> Map.put(:image, Map.take(struct, [:mediaid]))
    end
  end

  defmodule Video do
    @moduledoc false
    defstruct tousername: nil,
              fromusername: nil,
              createtime: nil,
              msgtype: "video",
              title: nil,
              mediaid: nil,
              description: nil

    def to_map(struct) do
      struct
      |> Map.delete(:__struct__)
      |> Map.take([:tousername, :fromusername, :msgtype, :createtime])
      |> Map.put(:video, Map.take(struct, ~w/title mediaid description/a))
    end
  end

  defmodule Voice do
    @moduledoc false
    defstruct tousername: nil,
              fromusername: nil,
              createtime: nil,
              msgtype: "voice",
              title: nil,
              mediaid: nil,
              description: nil

    def to_map(struct) do
      struct
      |> Map.delete(:__struct__)
      |> Map.take([:tousername, :fromusername, :msgtype, :createtime])
      |> Map.put(:voice, Map.take(struct, ~w/title mediaid description/a))
    end
  end

  defmodule Music do
    @moduledoc false
    defstruct tousername: nil,
              fromusername: nil,
              createtime: nil,
              msgtype: "music",
              title: nil,
              description: nil,
              musicurl: nil,
              hqmusicurl: nil,
              thumbmediaid: nil

    def to_map(struct) do
      struct
      |> Map.delete(:__struct__)
      |> Map.take([:tousername, :fromusername, :msgtype, :createtime])
      |> Map.put(
        :music,
        Map.take(
          struct,
          ~w/title description musicurl hqmusicurl thumbmediaid/a
        )
      )
    end
  end

  defmodule News do
    @moduledoc false
    alias Wechat.Message.XmlMessage.New

    defstruct tousername: nil,
              fromusername: nil,
              createtime: nil,
              msgtype: "news",
              articlecount: nil,
              articles: []

    def to_map(struct) do
      struct
      |> Map.delete(:__struct__)
      |> Map.take([:tousername, :fromusername, :msgtype, :createtime])
      |> Map.put(:articlecount, length(struct.articles))
      |> Map.put(:articles, struct.articles |> Enum.map(&New.to_map/1))
    end
  end

  defmodule New do
    @moduledoc false
    defstruct title: nil, description: nil, picurl: nil, url: nil

    def to_map(struct) do
      struct |> Map.delete(:__struct__)
    end
  end
end
