# ExWechat [![Build Status](https://travis-ci.org/h1u2i3/ex_wechat.svg?branch=master)](https://travis-ci.org/h1u2i3/ex_wechat.svg?branch=master) [![Coverage Status](https://coveralls.io/repos/github/h1u2i3/ex_wechat/badge.svg?branch=master)](https://coveralls.io/github/h1u2i3/ex_wechat?branch=master) [![Hex version](https://img.shields.io/hexpm/v/ex_wechat.svg "Hex version")](https://hex.pm/packages/ex_wechat)

Elixir/Phoenix wechat api wraper, ([documentation](http://hexdocs.pm/ex_wechat/)).

## Installation

1. Add `ex_wechat` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ex_wechat, "~> 0.1.5"}]
    end
    ```

2. Ensure `ex_wechat` is started before your application:

  ```elixir
  def application do
    [applications: [:ex_wechat]]
  end
  ```

## Usage

### Single Wechat api usage
1. Add config data(you can use [`direnv`](https://github.com/direnv/direnv) to set your `ENV`):

    ```elixir
    config :ex_wechat, ExWechat,
      appid: System.get_env("WECHAT_APPID") || "your appid",
      secret: System.get_env("WECHAT_APPSECRET") || "your app secret",
      token: System.get_env("WECHAT_TOKEN") || "your token",
    ```

2. Use the methods in `ExWechat` module, you can get all the method name
   from doc or from the definition files in `lib/apis`.

    ```elixir
    ExWechat.get_user_list
    ExWechat.get_menu

    ExWechat.Message.send_custom(openid, msgtype: "text", content: "Hello!")
    ```

### Multi-account apis usage
1. Add your own module:

    ```elixir
    defmodule Wechat.User do
      use ExWechat.Api, appid: "", secret: "", token: ""
    end

    defmodule Wechat.Doctor do
      use ExWechat.Api, appid: "", secret: "", token: ""
    end
    ```

2. Use the methods in `ExWechat` with the module you define:

    ```elixir
    Wechat.User.get_user_list
    Wechat.Doctor.get_user_list

    ExWechat.Message.send_custom(Wechat.User, openid, msgtype: "text", content: "Hello!")
    ExWechat.Message.send_custom(Wechat.Doctor, openid, msgtype: "text", content: "Hello!")
    ```

## Phoenix Plugs
1. Example usage with server verify and message responder:

    ```elixir
    defmodule Wechat.Router do
      use Wechat.Web, :router

      pipeline :api do
        plug :accepts, ["json"]
      end

      pipeline :customer do
        # single wechat app don't need to add api
        plug ExWechat.Plugs.WechatSignatureResponder

        # you can add your own api module(for multi-accounts support)
        plug ExWechat.Plugs.WechatSignatureResponder, api: Wechat.Customer

        plug ExWechat.Plugs.WechatMessageParser
      end

      scope "/customer_wechat", Wechat do
        pipe_through [:api, :customer]
        get "/", CustomerWechatController, :index
        post "/", CustomerWechatController, :create
      end
    end

    defmodule Wechat.CustomerWechatController do
      use Wechat.Web, :controller
      use ExWechat.Responde
    end
    ```
in your controller you can use the helper methods in `ExWechat.Responder`
to respond with user:

    ```elixir
    defp on_text_responder(conn),         do: conn
    defp on_image_responder(conn),        do: conn
    defp on_voice_responder(conn),        do: conn
    defp on_video_responder(conn),        do: conn
    defp on_shortvideo_responder(conn),   do: conn
    defp on_location_responder(conn),     do: conn
    defp on_link_responder(conn),         do: conn
    defp on_event_responder(conn),        do: conn
    ```
example controller use with `on_text_responder`:

    ```elixir
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
    ```

2. Example usage with wechat site (get wechat user info):

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
        plug ExWechat.Plugs.WechatWebsite, api: Wechat.Customer,
          url: "http://wechat.one-picture.com", scope: "snsapi_userinfo",
          state: Wechat.PageController

        # use the ExWechat(default), scope is snsapi_base(default)
        # use the request_id as state(default)
        # and set the redirect url you want to.
        plug ExWechat.Plugs.WechatWebsite,
          url: "http://wechat.one-picture.com"
      end

      scope "/", Wechat do
        pipe_through [:browser, :wechat_website]

        get "/", PageController, :index
        get "/about", PageController, :about
      end
    end
    ```
in your controller you can get the user's openid and the authorize data from conn:

    ```elixir
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

      def state(request_id) do
        # you can set the state you want.
        # or you can use the request_id to do other things.
        request_id
      end
    end
    ```

## The Mix Task (still in development)




## Todos

- [ ] Add Mix task(User, Menu, Message).
- [ ] Add more test(Plugs, Message, User).
- [ ] More Docs(maybe Wiki).


## License
MIT license
