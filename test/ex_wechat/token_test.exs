defmodule ExWechat.DemoTest do
  use ExUnit.Case
  use ExWechat.Base
  use ExWechat.TestHelper.Http

  defmodule Demo do
    use ExWechat.Api
  end
@endpoint "https://api.weixin.qq.com/cgi-bin"
  @data %{access_token: "token", expire_in: "7200"}

  setup do
    new :hackney
    on_exit fn -> unload() end
    :ok
  end

  test "expect get the data from server" do
    expect_response("#{@endpoint}/token",
      [grant_type: "client_credential", appid: appid, secret: secret], @data)

    assert @data == Demo.get_access_token
  end

  test "get access_token should write to cache" do
    del_access_token_cache
    expect_response("#{@endpoint}/token",
      [grant_type: "client_credential", appid: appid, secret: secret], @data)

    access_token = Demo.access_token
    cache = ConCache.get(:ex_wechat_token, 
                         :"ExWechat.DemoTest.Demo.access_token")

    assert access_token == cache
  end

  test "when cache exists should read from cache" do
    prepare_for_access_token_cache("token")
    expect_response("#{@endpoint}/token",
      [grant_type: "client_credential", appid: appid, secret: secret],
      %{access_token: "bad_token", expire_in: "7200"})

    access_token = Demo.access_token

    refute access_token == "bad_token"
    assert access_token == "token"
  end

  test "force get access_token will get the new access_token" do
    prepare_for_access_token_cache("token")
    expect_response("#{@endpoint}/token",
      [grant_type: "client_credential", appid: appid, secret: secret],
      %{access_token: "new_token", expire_in: "7200"})

    access_token = Demo.renew_access_token

    assert access_token == "new_token"
  end

  defp del_access_token_cache do
    :ex_wechat_token
    |> ConCache.ets
    |> :ets.tab2list
    |> Enum.each(fn({key, _}) ->
         ConCache.delete(:ex_wechat_token, key)
       end)
  end

  defp prepare_for_access_token_cache(data) do
    del_access_token_cache
    ConCache.put(:ex_wechat_token,
                 :"ExWechat.DemoTest.Demo.access_token", data)
  end
end
