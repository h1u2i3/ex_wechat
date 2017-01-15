use Mix.Config

config :get_server_ip,
  doc: """
    Get the wechat server ip.
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/getcallbackip",
  http: :get,
  params: [access_token: nil]
