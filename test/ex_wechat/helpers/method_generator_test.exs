defmodule ExWechat.Helpers.MethodGeneratorTest do
  use ExUnit.Case
  use ExWechat.Base

  import ExWechat.TestHelper.Http

  defmodule ApiDemo do
    use ExWechat.Api
    @api [:access_token]
  end

  @endpoint "https://api.weixin.qq.com/cgi-bin"
  @data "get real data"

  test "shoud generate the right methods" do
    methods = ApiDemo.__info__(:functions)

    assert Keyword.has_key?(methods, :access_token)
  end

  test "shoud add method that actually work" do
    expect_response("#{@endpoint}/token",
      [grant_type: "client_credential", appid: appid, secret: secret], @data)

    result = ApiDemo.get_access_token

    assert result == @data
  end
end
