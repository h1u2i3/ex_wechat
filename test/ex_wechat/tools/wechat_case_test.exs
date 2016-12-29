defmodule ExWechat.Tools.WechatCaseTest do
  use ExUnit.Case, async: true

  alias ExWechat.Tools.WechatCase

  test "should set the right wechat case env" do
    WechatCase.fake("xxx")
    fun = Application.get_env(:ex_wechat, :wechat_case)
    assert fun.(:whatever) == "xxx"
  after
    Application.delete_env(:ex_wechat, :wechat_case)
  end
end
