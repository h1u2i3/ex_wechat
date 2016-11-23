use Mix.Config

config :ex_wechat, ExWechat,
  appid: "yourappid",
  secret: "yourappsecret",
  token: "yourtoken",
  access_token_cache: "/tmp/access_token_test",
  api_definition_files: Path.join(__DIR__, "../test/apis")
