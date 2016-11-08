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

        use ExWechat.Api
        @api [:access_token]  # only add the access_token api method.

  """

  use ExWechat.Api
  use ExWechat.Base
  import ExWechat.Helpers.TimeHelper

  @api [:access_token] # only need the access_token api definition

  @doc """
    Get the access_token.
  """
  def _access_token do
    case File.stat(access_token_cache) do
      {:ok, %File.Stat{mtime: mtime}} ->
        access_token_generate_time = erl_datetime_to_unix_time(mtime)
        if access_token_valid?(access_token_generate_time) do
          read_access_token_from_cache
        else
          fetch_access_token_and_write_cache
        end
      {:error, _} ->
        fetch_access_token_and_write_cache
    end
  end

  @doc """
    Force to get the new access_token
  """
  def _force_get_access_token do
    fetch_access_token_and_write_cache
  end

  defp read_access_token_from_cache do
    {:ok, access_token} = File.read(access_token_cache)
    access_token
  end

  defp fetch_access_token_and_write_cache do
    token = get_access_token.access_token
    File.write access_token_cache, token
    token
  end

  defp access_token_valid?(timestamp) do
    current_unix_time - timestamp < 7190
  end
end
