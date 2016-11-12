defmodule ExWechat.Helpers.CryptoHelperTest do
  use ExUnit.Case, async: true

  import ExWechat.Helpers.CryptoHelper

  @string "test"
  @sha1_string "a94a8fe5ccb19ba61c4c0873d391e987982fbbd3"

  test "the sha hash match the string should return true" do
    assert sha1_equal? @string, @sha1_string
  end
end
