defmodule ExWechat do
  @moduledoc ~S"""
    An elixir Wechat api. Functional and clear.

    This sdk will read api definition from definition files.
    then it will automaticlly add all the function you define
    in these definition files.

    All the methods in definition file are like this:

        //---------------------
        //  access_token
        //---------------------

        @endpoint https://api.weixin.qq.com/cgi-bin

        # this is the doc you set for the function.

        function: function_name
        path: http request path
        http: the method use for request(get or post)
        params: the params needed for make the http request

    You also can add your own api definition files.
    Set the api definition folder in `config.exs`,
    then you can use the api you define.
    For example:

        # config/config.exs
        config :ex_wechat, ExWechat,
          appid: System.get_env("WECHAT_APPID"),
          secret: System.get_env("WECHAT_APPSECRET"),
          token: System.get_env("WECHAT_TOKEN"),
          access_token_cache: "/tmp/access_token"
          api_definition_files: Path.join(__DIR__, "lib/demo/apis")

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

    Normally, when you add:

        use ExWechat.Api

    to your module, this module will read all the api definition files,
    define and import all the medthod you put in api definition file,
    each method is a `get` or `post` http request.
    All the Http methods use `HTTPosion`.

        defmodule MenuController do
          use ExWechat.Api

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

  use ExWechat.Api
end
