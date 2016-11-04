defmodule ExWechat.TokenTest do
  use ExUnit.Case

  alias ExWechat.Token

  test "should get access_token from wechat server" do
    assert Token.access_token
  end

  #test "should get js_token from wechat server"
end
