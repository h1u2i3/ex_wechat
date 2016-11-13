defmodule ExWechatTest do
  use ExUnit.Case
  use ExWechat.Base
  use ExWechat.TestHelper.Http

  defmodule Demo do
    import ExWechat

    def demo_get_menu do
      get_menu
    end

    def demo_some_method do
      some_method
    end
  end

  setup do
    new :hackney
    on_exit fn -> unload() end
    :ok
  end

  test "should have the functions in api definition files" do
    prepare_for_access_token_cache("token")
    expect_response("https://api.weixin.qq.com/cgi-bin/menu/get",
      [access_token: "token"], "some_menu")

    result = Demo.demo_get_menu

    assert result == "some_menu"
  end

  test "should have the functions in user defined api" do
    expect_response("https://localhost/haha",
      [grant_type: "client_credential", appid: appid, secret: secret], "some_method")

    result = Demo.demo_some_method

    assert result == "some_method"
  end

  defp prepare_for_access_token_cache(data) do
    case File.exists?(access_token_cache) do
      true  ->
        File.rm!(access_token_cache)
        File.write!(access_token_cache, data)
      false ->
        File.write!(access_token_cache, data)
    end
  end
end
