defmodule ExWechat do
  @moduledoc """
    An elixir Wechat api. Functional and clear.
    You can add

        use ExWechat.Api

    to the module you want to have the api methods.
    The api methods are split into different file, you can import the function you want.

        use ExWechat.Api
        @api [:access_token, :user]

    This will import the api method about access_token and user.
  """

  use ExWechat.Api
end
