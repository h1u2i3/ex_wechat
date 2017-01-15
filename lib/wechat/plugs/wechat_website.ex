defmodule Wechat.Plugs.WechatWebsite do
  @moduledoc """
    Plug use for wechat site. A lot helper method.
  """
  import Plug.Conn

  alias Wechat.Http

  @open_endpoint "https://open.weixin.qq.com"
  @open_path "/connect/oauth2/authorize"

  @api_endpoint "https://api.weixin.qq.com"
  @api_path "/sns/oauth2/access_token"

  def init(options) do
    options
  end

  def call(conn, options) do
    case conn do
      %Plug.Conn{params: %{"code" => code}}  ->
        get_wechat_info(conn, code, options)
      _   ->
        scope = options[:scope] || "snsapi_base"
        conn
        |> put_resp_header("location", request_code_url(conn, scope, options))
        |> send_resp(302, "redirect")
        |> halt
    end
  end

  def state do
    "ex_wechat_state"
  end

  defp get_wechat_info(conn, code, options) do
    wechat_site_case = Application.get_env(:ex_wechat, :wechat_site_case)
    callback = &Http.parse_wechat_site/1

    result =
      cond do
        is_function(wechat_site_case) ->
          wechat_site_case.()
        true ->
          Http.get(request_auth_opts(code, options), callback)
      end

    conn
    |> assign(:wechat_result, result)
    |> put_session(:openid, result.openid)
  after
    Application.delete_env(:ex_wechat, :wechat_site_case)
  end

  defp request_auth_opts(code, options) do
    api = options[:api] || Wechat.Api
    appid = apply(api, :appid, [])
    secret = apply(api, :secret, [])

    [url: api_url(), params: [appid: appid, secret: secret,
      code: code, grant_type: "authorization_code"]]
  end

  defp request_code_url(_conn, scope, options) do
    api = options[:api] || Wechat.Api
    module = options[:state] || __MODULE__
    url = options[:url] || raise "You didn't set the redirect uri"

    appid = apply(api, :appid, [])
    state = apply(module, :state, [])

    "#{open_url()}?appid=#{appid}&redirect_uri=#{redirect_uri(url)}" <>
    "&response_type=code&scope=#{scope}&state=#{state}#wechat_redirect"
  end

  defp redirect_uri(url) do
    URI.encode_www_form url
  end

  defp api_url do
    @api_endpoint <> @api_path
  end

  defp open_url do
    @open_endpoint <> @open_path
  end
end
