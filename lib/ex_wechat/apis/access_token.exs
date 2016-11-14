use Mix.Config

config :get_access_token,
  doc: """
    Get the access_token from wechat server
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/token",
  http: :get,
  params: [grant_type: "client_credential", appid: nil, secret: nil]
