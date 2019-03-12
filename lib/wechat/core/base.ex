defmodule Wechat.Base do
  @moduledoc """
  Make module can get the config data.

      use Wechat.Base

  then, you can get the config data in your module.

      defmodule Wechat do
        use Wechat.Base
      end

      Wechat.appid  # your wechat app appid
      Wechat.secret # your wechat app appsecret
      Wechat.token  # your server's token for wechat
      ...

  You can set above config in `config.exs`:

      config :ex_wechat, Wechat,
        appid: System.get_env("WECHAT_APPID") || "your appid",
        secret: System.get_env("WECHAT_APPSECRET") || "your app secret",
        token: System.get_env("WECHAT_TOKEN") || "yout token",

  """

  defmacro __using__(opts) do
    config_methods =
      for key <- [:appid, :secret, :token, :aes] do
        configs =
          case opts do
            [] -> Application.get_env(:ex_wechat, Wechat) || []
            _ -> opts
          end

        quote do
          @doc false
          def unquote(key)() do
            unquote(Keyword.get(configs, key, nil) |> get_value)
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
        defdelegate appid(), to: Wechat.Api
        defdelegate secret(), to: Wechat.Api
        defdelegate token(), to: Wechat.Api
        defdelegate aes(), to: Wechat.Api
      end
    else
      quote do
        def appid, do: unquote(config)[:appid]
        def secret, do: unquote(config)[:secret]
        def token, do: unquote(config)[:token]
        def aes, do: unquote(config)[:aes]
      end
    end
  end

  # get system env
  defp get_value(value) when is_binary(value), do: value
  defp get_value(key) when is_atom(key), do: to_string(key)
  defp get_value({:system, key}), do: System.get_env(key)
  defp get_value(_), do: nil
end
