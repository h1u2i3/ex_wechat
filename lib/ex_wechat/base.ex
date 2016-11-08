defmodule ExWechat.Base do
  @moduledoc """
    Make module can get the config data.

        use ExWechat.Base

    then, you can get the config data in your module.

        defmodule Wechat do
          use ExWechat.Base
        end

        Wechat.appid  # your wechat app appid
        Wechat.secret # your wechat app appsecret
        Wechat.token  # your server's token for wechat
        Wechat.access_token_cache  # place the access_token saved.

    You can set above config in `config.exs`:

        config :ex_wechat, ExWechat,
          appid: System.get_env("WECHAT_APPID") || "your appid",
          secret: System.get_env("WECHAT_APPSECRET") || "your app secret",
          token: System.get_env("WECHAT_TOKEN") || "yout token",
          access_token_cache: "/tmp/access_token"
  """

  defmacro __using__(_opts) do
    for key <- [:appid, :secret, :token, :access_token_cache,
                :api_definition_files] do
      quote do
        @doc false
        def unquote(key)() do
          unquote(Application.get_env(:ex_wechat, ExWechat)[key])
        end
      end
    end
  end
end
