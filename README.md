# ExWechat

Elixir/Phoenix wechat api, ([documentation](http://hexdocs.pm/ex_wechat/)).

## Installation

1. Add `ex_wechat` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ex_wechat, "~> 0.1.2"}]
    end
    ```

2. Add config for your Wechat app:

    ```elixir
    config :ex_wechat, ExWechat,
      appid: System.get_env("WECHAT_APPID") || "your_appid",
      secret: System.get_env("WECHAT_APPSECRET") || "your_appsecret",
      token: System.get_env("WECHAT_TOKEN") || "your_token",
      access_token_cache: "/tmp/access_token"
    ```

## Usage

1. Add route for Wechat:

    ```elixir
    pipeline :api do
      plug :accepts, ["json"]
    end

    pipeline :wechat do
      plug ExWechat.Plugs.WechatSignatureResponder
      plug ExWechat.Plugs.WechatMessageParser
    end

    scope "/wechat", Demo do
      pipe_through [:api, :wechat]
      get "/", WechatController, :index
      post "/", WechatController, :create
    end
    ```
2. In your `WechatController`:

    ```elixir
    defmodule Demo.WechatController do
      use ExWechat.Responder    # interact with user, return message to user
      import ExWechat.Message   # function that parse and render wechat message
    end
    ```
You also can define your own function to react with user.
These functions are:

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
The following is an esay example(when receive text message from user, return user with text message that have reverse string):

    ```elixir
    defp on_text_responder(conn)
      # all the message are parsered and can be fetch with assigns[:message]
      message = conn.assigns[:message]  
      case message do
        %{content: content} ->
          reply_with(conn, build_message(%{
              msgtype: "text",
              from: message.tousername,
              to: message.fromusername,
              content: String.reverse(content)
            }))
        _   ->
          conn
      end
    end
    ```
For more document, please goto ([documentation](http://hexdocs.pm/ex_wechat/)).

## Wechat Api
1. You can import the Wechat Api to any module by:

    ```elixir
    use ExWechat.Api
    ```
And the api function are well classified by their function. If you only want to operate the follower in your wechat app:

    ```elixir
    defmodule Demo.UserController do
      use ExWechat.Api

      @api [:user]

      def index(conn, _opts) do
        # your code you want.
      end
    end
    ```
2. You can add more api methods by add method definitions file, for more api methods, please view the api definition files in `lib/ex_wechat/apis` folder.

## License
MIT license.
