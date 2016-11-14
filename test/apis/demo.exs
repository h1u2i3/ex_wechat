use Mix.Config

config :some_method,
  doc: """
    Get the access_token from wechat server
  """,
  endpoint: "https://localhost",
  path: "/haha",
  http: :get,
  params: [grant_type: "client_credential", appid: nil, secret: nil]
