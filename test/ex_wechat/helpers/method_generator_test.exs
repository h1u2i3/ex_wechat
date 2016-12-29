defmodule ExWechat.Helpers.MethodGeneratorTest do
  use ExUnit.Case, async: true
  use ExWechat.Base

  alias ExWechat.Tools.HttpCase

  defmodule ApiDemo do
    use ExWechat.Api
    @api [:access_token]
  end

  @data "get real data"

  test "shoud generate the right methods" do
    methods = ApiDemo.__info__(:functions)

    assert Keyword.has_key?(methods, :access_token)
  end

  test "shoud add method that actually work" do
    HttpCase.fake(@data)
    result = ApiDemo.get_access_token

    assert result == @data
  end
end
