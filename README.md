# ExWechat [![Build Status](https://travis-ci.org/h1u2i3/ex_wechat.svg?branch=master)](https://travis-ci.org/h1u2i3/ex_wechat.svg?branch=master) [![Coverage Status](https://coveralls.io/repos/github/h1u2i3/ex_wechat/badge.svg?branch=develop)](https://coveralls.io/github/h1u2i3/ex_wechat?branch=develop) [![Hex version](https://img.shields.io/hexpm/v/ex_wechat.svg "Hex version")](https://hex.pm/packages/ex_wechat)

Elixir/Phoenix wechat api wraper, ([documentation](http://hexdocs.pm/ex_wechat/)).

## Installation

1. Add `ex_wechat` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ex_wechat, "~> 0.1.6"}]
    end
    ```

2. Ensure `ex_wechat` is started before your application:

  ```elixir
  def application do
    [extra_applications: [:ex_wechat]]
  end
  ```
