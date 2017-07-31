# ExWechat
[![Build Status](https://travis-ci.org/h1u2i3/ex_wechat.svg?branch=master)](https://travis-ci.org/h1u2i3/ex_wechat.svg?branch=master) [![Coverage Status](https://coveralls.io/repos/github/h1u2i3/ex_wechat/badge.svg?branch=develop)](https://coveralls.io/github/h1u2i3/ex_wechat?branch=develop) [![Hex version](https://img.shields.io/hexpm/v/ex_wechat.svg "Hex version")](https://hex.pm/packages/ex_wechat)

Elixir/Phoenix wechat api wraper, ([documentation](http://hexdocs.pm/ex_wechat/)).

## 1. 设计原则和目标

1. 实现微信的所有方法。[`微信文档`](https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1445241432).

2. 所有的方法定义均在`/lib/wechat/core/apis/`文件夹中, 所有定义的方法会在编译时被添加到 `Wechat` 模块或者你自己定义的模块中，方法定义如下:

    ```elixir
    # doc 文档
    # endpoint 服务器路径
    # path 请求的路径
    # http 请求方法 get/post
    # params 必备参数, 对于必备的 access_token/wxcard_token/jsapi_token 直接设置为 nil
    doc: """
    Create user group
    """,
    endpoint: "https://api.weixin.qq.com/cgi-bin",
    path: "/groups/create",
    http: :post,
    params: [access_token: nil]
    ```

3. 定义的方法可以在定义文件中查看，也可以在文档中查看，方法的使用方式如下:

    ```elixir
    # 如果不需要额外的参数, 直接调用即可
    Wechat.get_user_list
    # 如果是 post 请求, 额外参数必须为 Map
    Wechat.create_ticket(%{expire_seconds: 3600, action_name: "QR_SCENE"})
    # 如果是 get 请求，额外参数为 Keyword
    Wechat.get_qrcode(ticket: ticket)
    ```

4. 为了尽量保证稳定性和可靠性，本项目只实现了常用的 `Wechat.Message` 和 `Wechat.User`, 当然你可以按照你自己的需求来定义, 例如你可以实现二维码的 Module (`Wechat.Qrcode`), 你可以通过 Import 导入你需要的方法，或者按照例子所示直接引入 Api 定义文件中的方法:

    ```elixir
    defmodule Wechat.Qrcode do
      use Wechat.Api
      # use @api to only import the methods defined in qrcode.exs
      # it contains the methods:
      # create_qrcode_ticket, get_qrcode
      @api [:qrcode]

      def create_ticket(scene, expire) when is_integer(scene) do
        create_qrcode_ticket(%{
          expire_seconds: expire,
          action_name: "QR_SCENE",
          action_info: %{scene: %{scene_id: scene}}
        })
      end

      def create_ticket(scene, expire) when is_binary(scene) do
        create_qrcode_ticket(%{
          expire_seconds: expire,
          action_name: "QR_STR_SCENE",
          action_info: %{scene: %{scene_str: scene}}
        })
      end

      #...

      def download(ticket, path) do
        # first urlencode
        encode_ticket = URI.encode_www_form(ticket)
        qrcode_data = get_qrcode(ticket: encode_ticket)
        File.write!(path, qrcode_data)
      end
    end
    ```

5. 提供可靠的测试方法，如何使用请查看底部关于测试的描述。

6. 对于本项目没有实现的方法，你可以按照 Api 定义文件的格式自行定义，再在项目中使用。

## 2. The Installation

1. Add `ex_wechat` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ex_wechat, "~> 0.1.8"}]
    end
    ```

2. Ensure `ex_wechat` is started before your application:

    ```elixir
    def application do
      [extra_applications: [:ex_wechat]]
    end
    ```

## 3. Basic Usage
### Single Account
1. Add config (you can use [`direnv`](https://github.com/direnv/direnv) to set your `ENV`):

    ```elixir
    config :ex_wechat, Wechat,
      appid: System.get_env("WECHAT_APPID") || "your appid",
      secret: System.get_env("WECHAT_APPSECRET") || "your app secret",
      token: System.get_env("WECHAT_TOKEN") || "your token",
      aes: Sestem.get_env("WECHAT_AES") || "your aes_key"
    ```

2. Use the methods in `Wechat` module, you can get all the method name from doc or from the definition files in `lib/apis`.

    ```elixir
    Wechat.get_user_list
    Wechat.get_menu

    Wechat.Message.send_custom(openid, msgtype: "text", content: "Hello!")
    ```

### Multi-account
1. Add your own module:

    ```elixir
    defmodule Wechat.User do
      use Wechat.Api, appid: "", secret: "", token: "", aes: ""
    end

    defmodule Wechat.Doctor do
      use Wechat.Api, appid: "", secret: "", token: "", aes: ""
    end
    ```

2. Use the methods in `Wechat` or the module you define:

    ```elixir
    Wechat.User.get_user_list
    Wechat.Doctor.get_user_list

    Wechat.Message.send_custom(Wechat.User, openid, msgtype: "text", content: "Hello!")
    Wechat.Message.send_custom(Wechat.Doctor, openid, msgtype: "text", content: "Hello!")
    ```

## 4. Phoenix Plugs
1. Example usage with server verify and message responder:

    ```elixir
    defmodule Wechat.Router do
      use Wechat.Web, :router

      pipeline :api do
        plug :accepts, ["json"]
      end

      pipeline :customer do
        # single wechat app don't need to add api
        plug Wechat.Plugs.WechatSignatureResponder
        plug Wechat.Plugs.WechatMessageParser

        # you can add your own api module(for multi-accounts support)
        plug Wechat.Plugs.WechatSignatureResponder, api: Wechat.Customer
        plug Wechat.Plugs.WechatMessageParser, api: Wechat.Customer
      end

      scope "/customer_wechat", Wechat do
        pipe_through [:api, :customer]
        get "/", CustomerWechatController, :index
        post "/", CustomerWechatController, :create
      end
    end

    defmodule Wechat.CustomerWechatController do
      use Wechat.Web, :controller
      use Wechat.Responder
    end
    ```

2. In your controller you can use the helper methods in `Wechat.Responder` to respond with user:

    ```elixir
    def on_text_responder(conn),         do: conn
    def on_image_responder(conn),        do: conn
    def on_voice_responder(conn),        do: conn
    def on_video_responder(conn),        do: conn
    def on_shortvideo_responder(conn),   do: conn
    def on_location_responder(conn),     do: conn
    def on_link_responder(conn),         do: conn
    def on_event_responder(conn),        do: conn
    def transfer_customer_service(conn), do: conn

    # example 1:
    # use text responder
    defmodule Wechat.CustomerWechatController do
      use Wechat.Web, :controller
      use Wechat.Responder

      import Wechat.Message

      defp on_text_responder(conn) do
        message = conn.assigns[:message]
        case message do
          %{content: content} ->
            reply_with(conn, generate_passive(message, msgtype: "text", content: String.reverse(content)))
          _ ->
            conn
        end
      end
    end

    # example 2:
    # you can transfer the message to custom service
    defmodule Wechat.CustomerWechatController do
      use Wechat.Web, :controller
      use Wechat.Responder

      import Wechat.Message

      defp transfer_customer_service(conn) do
        message = conn.assigns[:message]
        case message do
          %{content: "我要服务"} ->
            reply_with(conn, transfer_customer_service_msg(conn))
          _ ->
            conn
        end
      end
    end
    ```

3. Example usage with wechat site plug (get wechat user info), ([`微信网页授权`](https://mp.weixin.qq.com/wiki?t=resource/res_main&id=mp1421140842)):

    ```elixir
    defmodule Wechat.Router do
      use Wechat.Web, :router

      pipeline :browser do
        plug :accepts, ["html"]
        plug :fetch_session
        plug :fetch_flash
        plug :protect_from_forgery
        plug :put_secure_browser_headers
      end

      pipeline :wechat_website do
        # use the api you define, set the scope, the state module
        # and set the redirect url you want to.
        plug Wechat.Plugs.WechatWebsite, api: Wechat.Customer,
          host: "http://wechat.one-picture.com", scope: "snsapi_userinfo",
          state: Wechat.PageController

        # use the Wechat(default), scope is snsapi_base(default)
        plug Wechat.Plugs.WechatWebsite,
          host: "http://wechat.one-picture.com"
      end

      scope "/", Wechat do
        pipe_through [:browser, :wechat_website]

        get "/", PageController, :index
        get "/about", PageController, :about
      end
    end

    defmodule Wechat.PageController do
      use Wechat.Web, :controller

      def index(conn, _params) do
        # get the openid from session
        openid = conn |> get_session(:openid)
        # get the wechat authorize data from assins
        # include the access_token and other info,
        # you can use this info to get the user's infos.
        wechat_result = conn.assigns[:wechat_result]
        render conn, "index.html"
      end

      def about(conn, _params) do
        render(conn, "about.html")
      end

      def state do
        # you can set the state you want.
        'your_state'
      end
    end
    ```

## 4. Other Tools
### 4.1 JSApi config params

    ```elixir
    # single account
    Wechat.Jsapi.config_params(Wechat, [url: url])
    # multi-accounts
    Wechat.Jsapi.config_params(Wechat.User, [url: url])
    ```

## 5. Test Guide

    ```elixir
    # 所有微信访问方法返回内容设定
    # 具体使用方法见 test/core/token_test.exs
    Wechat.TestCase.fake(%{access_token: "token", expire_in: "7200"})

    # 制定 http request 的返回内容
    # 具体使用方法见 test/core/http_test.exs
    Wechat.TestCase.http_fake({:error, %{reason: "test"}})

    # 微信网页授权
    # 具体使用方法见 test/wechat/plugs/wechat_site_test.exs
    Wechat.TestCase.wechat_site_fake(%{openid: "openid"})
    ```

## 6. Add Custom Function


## 7. License
MIT license
