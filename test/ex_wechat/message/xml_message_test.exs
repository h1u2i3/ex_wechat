defmodule ExWechat.XmlMessageTest do
  use ExUnit.Case, async: true

  alias ExWechat.Message.XmlMessage
  import :meck
  import ExWechat.TestHelper.AssertHelper

  setup do
    new ExWechat.Helpers.TimeHelper
    on_exit fn -> unload() end
    :ok
  end

  def text do
    %{
      fromusername: "from",
      tousername: "to",
      msgtype: "text",
      content: "hello"
    }
  end

  def text_params do
    %{
      fromusername: "from",
      tousername: "to",
      msgtype: "text",
      content: "hello"
    }
  end

  def text_xml do
    """
    <xml>
    <ToUserName><![CDATA[to]]></ToUserName>
    <FromUserName><![CDATA[from]]></FromUserName>
    <CreateTime>1478942475</CreateTime>
    <MsgType><![CDATA[text]]></MsgType>
    <Content><![CDATA[hello]]></Content>
    </xml>
    """
  end

  def voice do
    %{
      fromusername: "from",
      tousername: "to",
      msgtype: "voice",
      voice: %{
        mediaid: "id"
      }
    }
  end

  def voice_params do
    %{
      fromusername: "from",
      tousername: "to",
      msgtype: "voice",
      mediaid: "id"
    }
  end

  def voice_xml do
    """
    <xml>
    <ToUserName><![CDATA[to]]></ToUserName>
    <FromUserName><![CDATA[from]]></FromUserName>
    <CreateTime>1478942475</CreateTime>
    <MsgType><![CDATA[voice]]></MsgType>
    <Voice>
    <MediaId><![CDATA[id]]></MediaId>
    </Voice>
    </xml>
    """
  end

  def video do
    %{
      fromusername: "from",
      tousername: "to",
      msgtype: "video",
      video: %{
        title: "title",
        mediaid: "id",
        description: "description"
      }
    }
  end

  def video_params do
    %{
      fromusername: "from",
      tousername: "to",
      msgtype: "video",
      title: "title",
      mediaid: "id",
      description: "description"
    }
  end

  def video_xml do
    """
    <xml>
    <ToUserName><![CDATA[to]]></ToUserName>
    <FromUserName><![CDATA[from]]></FromUserName>
    <CreateTime>1478942475</CreateTime>
    <MsgType><![CDATA[video]]></MsgType>
    <Video>
    <MediaId><![CDATA[id]]></MediaId>
    <Title><![CDATA[title]]></Title>
    <Description><![CDATA[description]]></Description>
    </Video>
    </xml>
    """
  end

  def image do
    %{
      fromusername: "from",
      tousername: "to",
      msgtype: "image",
      image: %{
        mediaid: "id"
      }
    }
  end

  def image_params do
    %{
      fromusername: "from",
      tousername: "to",
      msgtype: "image",
      mediaid: "id"
    }
  end

  def image_xml do
    """
    <xml>
    <ToUserName><![CDATA[to]]></ToUserName>
    <FromUserName><![CDATA[from]]></FromUserName>
    <CreateTime>1478942475</CreateTime>
    <MsgType><![CDATA[image]]></MsgType>
    <Image>
    <MediaId><![CDATA[id]]></MediaId>
    </Image>
    </xml>
    """
  end

  def news do
    %{
      fromusername: "from",
      tousername: "to",
      msgtype: "news",
      articlecount: "2",
      articles:
        %{
          item: [
            %{
                title: "title",
                description: "description",
                picurl: "picurl",
                url: "url"
              },
             %{
                title: "title",
                description: "description",
                picurl: "picurl",
                url: "url"
             }]
         }
    }
  end

  def news_params do
    %{
      fromusername: "from",
      tousername: "to",
      msgtype: "news",
      articlecount: "2",
      articles:
           [%{
                title: "title",
                description: "description",
                picurl: "picurl",
                url: "url"
              },
             %{
                title: "title",
                description: "description",
                picurl: "picurl",
                url: "url"
             }]
    }
  end

  def news_xml do
    """
    <xml>
    <ToUserName><![CDATA[to]]></ToUserName>
    <FromUserName><![CDATA[from]]></FromUserName>
    <CreateTime>1478942475</CreateTime>
    <MsgType><![CDATA[news]]></MsgType>
    <ArticleCount>2</ArticleCount>
    <Articles>
      <item>
      <Title><![CDATA[title]]></Title>
      <Description><![CDATA[description]]></Description>
      <PicUrl><![CDATA[picurl]]></PicUrl>
      <Url><![CDATA[url]]></Url>
      </item>
      <item>
      <Title><![CDATA[title]]></Title>
      <Description><![CDATA[description]]></Description>
      <PicUrl><![CDATA[picurl]]></PicUrl>
      <Url><![CDATA[url]]></Url>
      </item>
    </Articles>
    </xml>
    """
  end

  def music do
    %{
      fromusername: "from",
      tousername: "to",
      msgtype: "music",
      music: %{
        title: "title",
        description: "description",
        musicurl: "musicurl",
        hqmusicurl: "hqmusicurl",
        thumbmediaid: "thumbmediaid"
      }
    }
  end

  def music_params do
    %{
      fromusername: "from",
      tousername: "to",
      msgtype: "music",
      title: "title",
      description: "description",
      musicurl: "musicurl",
      hqmusicurl: "hqmusicurl",
      thumbmediaid: "thumbmediaid"
    }
  end

  def music_xml do
    """
    <xml>
    <ToUserName><![CDATA[to]]></ToUserName>
    <FromUserName><![CDATA[from]]></FromUserName>
    <CreateTime>1478942475</CreateTime>
    <MsgType><![CDATA[music]]></MsgType>
    <Music>
    <Title><![CDATA[title]]></Title>
    <Description><![CDATA[description]]></Description>
    <MusicUrl><![CDATA[musicurl]]></MusicUrl>
    <HQMusicUrl><![CDATA[hqmusicurl]]></HQMusicUrl>
    <ThumbMediaId><![CDATA[thumbmediaid]]></ThumbMediaId>
    </Music>
    </xml>
    """
  end

  for message_kind <- [:text, :voice, :video, :image, :news, :music] do
    test "should get the right #{message_kind} xml message" do
      expect(ExWechat.Helpers.TimeHelper, :current_unix_time, 0, 1478942475)
      xml_msg = __MODULE__
                |> apply(unquote(String.to_atom("#{message_kind}_params")), [])
                |> XmlMessage.build

      assert_equal_string xml_msg,
        apply(__MODULE__, unquote("#{message_kind}_xml" |> String.to_atom), [])
    end

    test "should get the right #{message_kind} map value" do
      msg_map = __MODULE__
                |> apply(unquote(String.to_atom("#{message_kind}_xml")), [])
                |> XmlMessage.parse
                |> Map.delete(:createtime)
      assert msg_map ==
        apply(__MODULE__, unquote(message_kind), [])
    end
  end
end
