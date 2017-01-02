use Mix.Config

config :get_short_url,
  doc: """
    Get the short url
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/shorturl",
  http: :post,
  params: [access_token: nil]
