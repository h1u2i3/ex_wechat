use Mix.Config

config :get_access_token,
  doc: """
    Get the access_token from wechat server
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/token",
  http: :get,
  params: [grant_type: "client_credential", appid: nil, secret: nil]

config :get_jsapi_ticket,
  doc: """
    Get the jsapi ticket from wechat server
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/ticket/getticket",
  http: :get,
  params: [access_token: nil, type: "jsapi"]

config :get_wxcard_ticket,
  doc: """
    Get the wxcard ticket from wechat server
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/ticket/getticket",
  http: :get,
  params: [access_token: nil, type: "wx_card"]
