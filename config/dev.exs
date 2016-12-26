use Mix.Config

config :ex_wechat, ExWechat,
  appid: System.get_env("WECHAT_APPID"),
  secret: System.get_env("WECHAT_APPSECRET"),
  token: System.get_env("WECHAT_TOKEN") || "yout token"  
