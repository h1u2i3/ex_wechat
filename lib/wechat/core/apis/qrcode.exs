use Mix.Config

config :create_qrcode_ticket,
  doc: """
    Generate qrcode ticket.
  """,
  endpoint: "https://api.weixin.qq.com/cgi-bin",
  path: "/qrcode/create",
  http: :post,
  params: [access_token: nil]

config :get_qrcode,
  doc: """
    Get qrcode with ticket.
  """,
  endpoint: "https://mp.weixin.qq.com/cgi-bin",
  path: "/showqrcode",
  http: :get,
  params: []
