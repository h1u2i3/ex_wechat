use Mix.Config

config :ex_wechat, ExWechat,
  appid: System.get_env("WECHAT_APPID") || "yourappid",
  secret: System.get_env("WECHAT_APPSECRET") || "yourappsecret",
  token: System.get_env("WECHAT_TOKEN") || "yourtoken",
  access_token_cache: "/tmp/access_token_test",
  api_definition_files: Path.join(__DIR__, "../test/apis")
