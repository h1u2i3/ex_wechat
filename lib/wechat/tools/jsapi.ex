defmodule Wechat.Jsapi do
  @moduledoc """
  return Jsapi config params
  """
  import Wechat.Helpers.CryptoHelper

  def config_params(module, url: url) do
    jsapi_ticket = apply(module, :jsapi_ticket, [])
    IO.inspect(jsapi_ticket)
    noncestr = generate_nonce_str()

    params = %{
      jsapi_ticket: jsapi_ticket,
      url: url,
      timestamp: :os.system_time(:second),
      noncestr: noncestr
    }

    params
    |> Map.put(:signature, wechat_sha(params))
    |> Map.put(:appid, apply(module, :appid, []))
  end
end
