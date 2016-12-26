use Mix.Config

config :ex_wechat, ExWechat,
  appid: {:system, "WECHAT_APPID"},
  secret: {:system, "WECHAT_APPSECRET"},
  token: {:system, "WECHAT_TOKEN"}
