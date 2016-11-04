# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :ex_wechat, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:ex_wechat, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :ex_wechat, ExWechat,
  appid: System.get_env("WECHAT_APPID") || "wx96f0c06c7dfb1cb3",
  secret: System.get_env("WECHAT_APPSECRET") || "d4624c36b6795d1d99dcf0547af5443d",
  token: System.get_env("WECHAT_TOKEN") || "06d53b73e95af362de834a20",
  access_token_cache: "/tmp/access_token"

# add this config to prevent the accidental error when make a request.
# https://github.com/edgurgel/httpoison/issues/130
config :ssl, protocol_version: :"tlsv1.2"
