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
        ...

    You can set above config in `config.exs`:

        config :ex_wechat, ExWechat,
          appid: System.get_env("WECHAT_APPID") || "your appid",
          secret: System.get_env("WECHAT_APPSECRET") || "your app secret",
          token: System.get_env("WECHAT_TOKEN") || "yout token",

  """

  defmacro __using__(opts) do
    config_methods =
      for key <- [:appid, :secret, :token] do
        configs = case opts do
                    []  -> Application.get_env(:ex_wechat, ExWechat) || []
                    _   -> opts
                  end
        quote do
          @doc false
          def unquote(key)() do
            unquote(Keyword.get(configs, key, nil))
          end
        end
      end

    quote do
      unquote(config_methods)
    end
  end

  @doc """
  Define base method in ast format to support multi-accounts.
  """
  def quoted_base_method(config) do
    if Enum.empty?(config) do
      quote do
        defdelegate appid(), to: ExWechat.Api
        defdelegate secret(), to: ExWechat.Api
        defdelegate token(), to: ExWechat.Api
      end
    else
      quote do
        def appid, do: unquote(config)[:appid]
        def secret, do: unquote(config)[:secret]
        def token, do: unquote(config)[:token]
      end
    end
  end
end
