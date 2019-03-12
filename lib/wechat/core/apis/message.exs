use Mix.Config

config :send_custom_message,
  doc: """
  Send custom message to user.
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/message/custom/send",
  http: :post,
  params: [access_token: nil]

config :send_template_message,
  doc: """
  Send Template message to user.
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/message/template/send",
  http: :post,
  params: [access_token: nil]

config :send_mass_message,
  doc: """
  Send Mass message to user.
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/message/mass/send",
  http: :post,
  params: [access_token: nil]
