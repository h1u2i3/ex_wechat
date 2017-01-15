defmodule Wechat.BaseTest do
  use ExUnit.Case
  use Wechat.Base

  test "should get appid" do
    assert appid() == Application.get_env(:ex_wechat, Wechat)[:appid]
  end

  test "should get appsecret" do
    assert secret() == Application.get_env(:ex_wechat, Wechat)[:secret]
  end

  test "should get token" do
    assert token() == Application.get_env(:ex_wechat, Wechat)[:token]
  end
end
