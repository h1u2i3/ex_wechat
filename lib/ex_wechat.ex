defmodule ExWechat do
  @moduledoc """
    An elixir Wechat api. Functional and clear.
    All the methods in definition file are like this:

        #---------------------
        #  access_token
        #---------------------
        doc: get the access_token
        function: get_access_token
        path: /token
        http: get
        params: grant_type=client_credential, appid, secret

    When you add:

        use ExWechat.Api

    to your module, this module will read all the api definition files, and parse the method data,
    then use these definitions to dinamyicly define methods, each method is a `get` or `post` http request.
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

    When use a `post` method, it is you responsibility to offer the right data(Elixir Map), when post data,
    it will convert to json by the api.
  """

  use ExWechat.Api
end
