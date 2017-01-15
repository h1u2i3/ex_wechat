defmodule Wechat.TestCaseTest do
  use ExUnit.Case, async: true

  alias Wechat.TestCase

  test "should set the right wechat case env" do
    TestCase.fake("xxx")
    fun = Application.get_env(:ex_wechat, :wechat_case)
    assert fun.() == "xxx"
  after
    Application.delete_env(:ex_wechat, :wechat_case)
  end

  test "should set the right http case env" do
    TestCase.http_fake("xxx")
    fun = Application.get_env(:ex_wechat, :http_case)
    assert fun.() == "xxx"
  after
    Application.delete_env(:ex_wechat, :http_case)
  end

  test "should set the right wechat site case env" do
    TestCase.wechat_site_fake("xxx")
    fun = Application.get_env(:ex_wechat, :wechat_site_case)
    assert fun.() == "xxx"
  after
    Application.delete_env(:ex_wechat, :wechat_site_case)
  end
end
