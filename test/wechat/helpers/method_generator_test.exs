defmodule Wechat.Helpers.MethodGeneratorTest do
  use ExUnit.Case, async: true
  use Wechat.Base

  alias Wechat.TestCase

  defmodule ApiDemo do
    use Wechat.Api
    @api [:access_token]
  end

  @data "get real data"

  test "shoud generate the right methods" do
    methods = ApiDemo.__info__(:functions)

    assert Keyword.has_key?(methods, :access_token)
  end

  test "shoud add method that actually work" do
    TestCase.http_fake(@data)
    result = ApiDemo.get_access_token(& &1)

    assert result == @data
  end
end
