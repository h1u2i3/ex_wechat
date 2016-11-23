defmodule ExWechat.BaseTest do
  use ExUnit.Case
  use ExWechat.Base

  test "should get appid" do
    assert appid == Application.get_env(:ex_wechat, ExWechat)[:appid]
  end

  test "should get appsecret" do
    assert secret == Application.get_env(:ex_wechat, ExWechat)[:secret]
  end

  test "should get token" do
    assert token == Application.get_env(:ex_wechat, ExWechat)[:token]
  end
end
