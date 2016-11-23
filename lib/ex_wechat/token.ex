defmodule ExWechat.Token do
  @moduledoc """
    Wechat Token fetcher.

    First get the token from cache, if invalid then get from the wechat server,
    `access_token` cache can be set in `config.exs`.

        config :ex_wechat, ExWechat,
          appid: System.get_env("WECHAT_APPID") || "your appid",
          secret: System.get_env("WECHAT_APPSECRET") || "your app secret",
          token: System.get_env("WECHAT_TOKEN") || "yout token",

  """

  @doc """
  Get the access token from wechat server.
  """
  def _access_token(module) do
    _token(module, :access_token)
  end

  @doc """
  Get the jsapi ticket from wechat server.
  """
  def _jsapi_ticket(module) do
    _token(module, :jsapi_ticket)
  end

  @doc """
  Get the wxcard ticket from wechat server.
  """
  def _wxcard_ticket(module) do
    _token(module, :wxcard_ticket)
  end

  @doc """
    Force to get the new token
  """
  def _force_get_token(module, token_kind) do
    fetch_token_and_write_cache(module, token_kind)
  end

  defp _token(module, token_kind) do
    token = ConCache.get(:ex_wechat_token, token_key(module, token_kind))
    case token do
      nil -> fetch_token_and_write_cache(module, token_kind)
      _   -> token
    end
  end

  defp fetch_token_and_write_cache(module, token_kind) do
    method = "get_#{token_kind}" |> String.to_atom
    response = apply(module, method, [])

    token = case token_kind do
      :access_token -> response[token_kind]
      _             -> response[:ticket]
    end

    ConCache.put(:ex_wechat_token, token_key(module, token_kind), token)
    token
  end

  defp token_key(module, token_kind) do
    "#{Macro.to_string(module)}.#{token_kind}"
    |> String.to_atom
  end
end
