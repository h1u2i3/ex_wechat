defmodule ExWechat.TokenTest do
  use ExUnit.Case

  alias ExWechat.Token

  test "should get access_token from wechat server" do
    assert Token._access_token
  end
end
