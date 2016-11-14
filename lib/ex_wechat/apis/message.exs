use Mix.Config

config :send_custom_message,
  doc: """
    Send custom message to user.
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/message/custom/send",
  http: :post,
  params: [access_token: nil]
