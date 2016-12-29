defmodule ExWechat.Tools.HttpCaseTest do
  use ExUnit.Case, async: true

  alias ExWechat.Tools.HttpCase

  test "should set the right http case env" do
    HttpCase.fake("xxx")
    fun = Application.get_env(:ex_wechat, :http_case)
    assert fun.(:whatever) == "xxx"
  after
    Application.delete_env(:ex_wechat, :http_case)
  end
end
