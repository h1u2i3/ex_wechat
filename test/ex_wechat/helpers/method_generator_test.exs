defmodule ExWechat.Helpers.MethodGeneratorTest do
  use ExUnit.Case
  use ExWechat.Base
  use ExWechat.TestHelper.Http

  defmodule ApiDemo do
    use ExWechat.Api
    @api [:demo]
  end

  @endpoint "https://localhost"
  @data "get real data"

  setup do
    new :hackney
    on_exit fn -> unload() end
    :ok
  end

  test "shoud generate the right methods" do
    methods = ApiDemo.__info__(:functions)

    assert Keyword.has_key?(methods, :some_method)
  end

  test "shoud add method that actually work" do
    expect_response("#{@endpoint}/haha",
      [grant_type: "client_credential", appid: appid, secret: secret], @data)

    result = ApiDemo.some_method

    assert result == @data
  end
end
