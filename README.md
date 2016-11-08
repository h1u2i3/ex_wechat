# ExWechat

Elixir/Phoenix wechat api, ([documentation](http://hexdocs.pm/ex_wechat/)).
Issues and pullrequests are welcome.

Still in development, so there may be some bugs.

## Installation

1. Add `ex_wechat` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ex_wechat, "~> 0.1.3"}]
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
Then your application should work.

## Advanced Usage

1. You can interact with follower ( when receives text message from user, it will return a text message with reverse text ):

    ```elixir
    defmodule Wechat.WechatController do
      require Logger

      use Wechat.Web, :controller
      use ExWechat.Responder

      import ExWechat.Message

      defp on_text_responder(conn) do
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
    end
    ```
 Methods you can override:

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
these methods must return a `Plug.Conn`, just choose what you need.

2. You can import the Wechat Api to any module by:

    ```elixir
    use ExWechat.Api
    ```
All api function are well classified by their function, the api definition files are in `lib/ex_wechat/apis` folder.
If you only want to operate the follower in your wechat app:

    ```elixir
    defmodule Demo.UserController do
      use ExWechat.Api

      @api [:user]

      def index(conn, _opts) do
        # your code you want.
        get_user_list  # return user list
      end
    end
    ```
if you didn't add the `@api` attribute, it will imports all the api methods to the module.

3. With `ExWechat` you can add your own api methods. Set the api definition folder in `config.exs`, then you can use the api you define.
For example:

    ```elixir
    # config/config.exs
    config :ex_wechat, ExWechat,
      appid: System.get_env("WECHAT_APPID"),
      secret: System.get_env("WECHAT_APPSECRET"),
      token: System.get_env("WECHAT_TOKEN"),
      access_token_cache: "/tmp/access_token"
      api_definition_files: Path.join(__DIR__, "lib/demo/apis")

    # api definition file
    # lib/demo/apis/simple_user
    @endpoint https://api.weixin.qq.com/cgi-bin

    # get user list
    function: get_user_list
    path: /user/get
    http: get
    params: access_token

    # web/controller/user_controller.ex
    defmodule Demo.UserController do
      use Demo.Web, :controller
      use ExWechat.Api

      @api [:simple_user] # file name of the api definition file

      def index(conn, _) do
        get_user_list
      end
    end
    ```
4. You can get all the methods defined by check the api definition file, or goto ([documentation](http://hexdocs.pm/ex_wechat/)) and check the `ExWechat` module, of course, you can add your own api definition too.

## Some Tips
1. Upload media to Wechat:

    ```elixir
    iex(2)> ExWechat.upload_media {:multipart, [{:file, "/Users/xiaohui/Desktop/xyz.jpg"}]}, type: "image"
    %{created_at: 1478594562, media_id: "NgGUXaSTGizWyG5Kc0xpydHHIm2PGy68ZViXmpXnojYLV7pw-6zuZaRkTu1cnhja", type: "image"}
    ```
2. Read media from wechat server:

    ```elixir
    iex(1)> ExWechat.get_media media_id: "NgGUXaSTGizWyG5Kc0xpydHHIm2PGy68ZViXmpXnojYLV7pw-6zuZaRkTu1cnhja"
    <<255, 216, 255, 225, 1, 130, 69, 120, 105, 102, 0, 0, 77, 77, 0, 42, 0, 0, 0,
      8, 0, 12, 1, 0, 0, 3, 0, 0, 0, 1, 4, 0, 0, 0, 1, 1, 0, 3, 0, 0, 0, 1, 3, 124,
      0, 0, 1, 2, 0, 3, ...>>
    iex(2)> File.write! "/Users/xiaohui/Desktop/y.jpg", ExWechat.get_media media_id: "NgGUXaSTGizWyG5Kc0xpydHHIm2PGy68ZViXmpXnojYLV7pw-6zuZaRkTu1cnhja"
    :ok
    ```
3. Because we got the base usage with Wechat Api, we can define our own module to do more semantic work.
Media example:

    ```elixir
    defmodule Wechat.Media do
      use ExWechat.Api

      @api [:media]

      def upload_image(path) do
        upload_media {:multipart, [{:file, path}]}, type: "image"
      end

      def download(media_id) do
        get_media media_id: media_id
      end
    end

    Wechat.Media.upload_media("/Users/xiaohui/Desktop/xyz.jpg")
    Wechat.Media.download("NgGUXaSTGizWyG5Kc0xpydHHIm2PGy68ZViXmpXnojYLV7pw-6zuZaRkTu1cnhja")
    ```
User example:

    ```elixir
    defmodule Wechat.User do
      use ExWechat.Api

      @api [:user]

      def info(openid)
        get_user_info openid: openid
      end

      def list do
        get_user_list
      end
    end
    ```
in this Wechat Api sdk, I don't add these modules, I let you to create your own.
 
## License
MIT license.
