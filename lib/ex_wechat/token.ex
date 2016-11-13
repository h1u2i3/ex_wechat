defmodule ExWechat.Token do
  @moduledoc """
    Wechat access_token.

    First get the token from cache, if invalid then get from the wechat server,
    `access_token` cache can be set in `config.exs`.

        config :ex_wechat, ExWechat,
          appid: System.get_env("WECHAT_APPID") || "your appid",
          secret: System.get_env("WECHAT_APPSECRET") || "your app secret",
          token: System.get_env("WECHAT_TOKEN") || "yout token",
          access_token_cache: "/tmp/access_token"

  """
  import ExWechat.Helpers.TimeHelper

  @doc """
    Get the access_token.
  """
  def _access_token(module) do
    cache = token_cache(module)
    case File.stat(cache) do
      {:ok, %File.Stat{mtime: mtime}} ->
        access_token_generate_time = erl_datetime_to_unix_time(mtime)
        if access_token_valid?(access_token_generate_time) do
          read_access_token_from_cache(module)
        else
          fetch_access_token_and_write_cache(module)
        end
      {:error, _} ->
        fetch_access_token_and_write_cache(module)
    end
  end

  @doc """
    Force to get the new access_token
  """
  def _force_get_access_token(module) do
    fetch_access_token_and_write_cache(module)
  end

  defp read_access_token_from_cache(module) do
    {:ok, access_token} = File.read(token_cache(module))
    access_token
  end

  defp fetch_access_token_and_write_cache(module) do
    response = apply(module, :get_access_token, [])
    token = response.access_token
    File.write token_cache(module), token
    token
  end

  defp access_token_valid?(timestamp) do
    current_unix_time - timestamp < 7190
  end

  defp token_cache(module) do
    apply(module, :access_token_cache, [])
  end
end
