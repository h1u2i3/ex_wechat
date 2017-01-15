defmodule Wechat do
  @moduledoc ~S"""
    An elixir Wechat api. Functional and clear.

    This sdk will read api definition from definition files.
    then it will automaticlly add all the function you define
    in these definition files.

    All the methods in definition file are like this:

    You also can add your own api definition files.
    Set the api definition folder in `config.exs`,
    then you can use the api you define.
    For example:

        # config/config.exs
        config :ex_wechat, Wechat,
          appid: System.get_env("WECHAT_APPID"),
          secret: System.get_env("WECHAT_APPSECRET"),
          token: System.get_env("WECHAT_TOKEN"),
          access_token_cache: "/tmp/access_token"
          api_definition_files: Path.join(__DIR__, "lib/demo/apis")

        # lib/demo/apis/simple_user

        use Mix.Config

        config :create_user_tag,
          doc: "create user tag"
          endpoint: "https://api.weixin.qq.com/cgi-bin",
          path: "/tags/create",
          http: :post,
          params: [access_token: nil]

        # web/controller/user_controller.ex
        defmodule Demo.UserController do
          use Demo.Web, :controller
          use Wechat.Api

          @api [:simple_user] # file name of the api definition file
        end

    Normally, when you add:

        use Wechat.Api

    to your module, this module will read all the api definition files,
    define and import all the medthod you put in api definition file,
    each method is a `get` or `post` http request.
    All the Http methods use `HTTPosion` for request.

        defmodule MenuController do
          use Wechat.Api

          @api [:menu]

          # post method
          create_menu(post_body, extra_params \\ [])
          # get method
          get_menu(extra_params \\ [])
        end

    You can only import the menu api by add:

        @api [:menu]

    When use a `post` method, it is you responsibility to offer
    the right data(Elixir Map), when post data,
    it will convert to json by the api.
  """

  use Application
  use Wechat.Api

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      worker(Wechat.Token, [[name: Wechat.Token]]),
      :hackney_pool.child_spec(:wechat_pool, hackney_config())
    ]

    opts = [strategy: :one_for_one, name: Wechat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp hackney_config do
    [timeout: 15000, max_connections: 100]
  end
end
