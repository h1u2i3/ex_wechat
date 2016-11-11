defmodule ExWechat.Plugs.WechatWebsite do
  use ExWechat.Base
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    case conn do
      %Plug.Conn{params: %{"code" => code}}  ->
        IO.inspect HTTPoison.get! request_auth_url(code)
        conn
      _   ->
        conn
        |> put_resp_header("location", request_code_url)
        |> send_resp(302, "redirect")
    end
  end

  def request_auth_url(code) do
    "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{appid}&secret=#{secret}" <>
    "&code=#{code}&grant_type=authorization_code"
  end

  def request_code_url(scope \\ "snsapi_base") do
    "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{appid}&redirect_uri=#{redirect_uri}" <>
    "&response_type=code&scope=#{scope}&state=123456#wechat_redirect"
  end

  def redirect_uri do
    URI.encode_www_form "http://wechat.one-picture.com"
  end
end
