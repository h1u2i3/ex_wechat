use Mix.Config

config :ex_wechat, Wechat,
  appid: "yourappid",
  secret: "yourappsecret",
  token: "yourtoken"

config :phoenix, :json_library, Jason
