# ExWechat [![Build Status](https://travis-ci.org/h1u2i3/ex_wechat.svg?branch=master)](https://travis-ci.org/h1u2i3/ex_wechat.svg?branch=master) [![Coverage Status](https://coveralls.io/repos/github/h1u2i3/ex_wechat/badge.svg?branch=master)](https://coveralls.io/github/h1u2i3/ex_wechat?branch=master) [![Hex version](https://img.shields.io/hexpm/v/ex_wechat.svg "Hex version")](https://hex.pm/packages/ex_wechat) [![Hex downloads](https://img.shields.io/hexpm/dt/ex_wechat.svg "Hex downloads")](https://hex.pm/packages/ex_wechat)

Elixir/Phoenix wechat api, ([documentation](http://hexdocs.pm/ex_wechat/)).

## Installation

1. Add `ex_wechat` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ex_wechat, "~> 0.1.4"}]
    end
    ```

## Api Usage

### For single Wechat App
1. Add config data:

    ```elixir
    config :ex_wechat, ExWechat,
      appid: System.get_env("WECHAT_APPID") || "your appid",
      secret: System.get_env("WECHAT_APPSECRET") || "your app secret",
      token: System.get_env("WECHAT_TOKEN") || "yout token",
      access_token_cache: "/tmp/access_token",
      api_definition_files: "your_api_definition_folder"
    ```

2. Use api with `ExWechat` or other ExWechat module, you can get the methods
   from docs.

    ```elixir
    ExWechat.get_user_list
    ExWechat.get_menu

    ExWechat.Message.to(Wechat.User, openid, wechat_message_params)
    ```

### For multi accounts.
1. Add your own module with Wechat Api.

    ```elixir
    defmodule Wechat.User do
      use ExWechat.Api,
            appid: "", secret: "",
            token: "", access_token_cache: ""
    end

    defmodule Wechat.Doctor do
      use ExWechat.Api,
        appid: "", secret: "",
        token: "", access_token_cache: ""
    end
    ```

2. User the module you define, or use ExWechat's other module.

    ```elixir
    Wechat.User.get_user_list
    Wechat.Doctor.get_user_list

    ExWechat.Message.send_custom(Wechat.User, openid, wechat_message_params)
    ExWechat.Message.send_custom(Wechat.Doctor, openid, wechat_message_params)
    ```

## Phoenix


## License
MIT license.
