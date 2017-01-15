defmodule Wechat.Helpers.CryptoHelperTest do
  use ExUnit.Case, async: true

  import Wechat.Helpers.CryptoHelper

  @string ["test", "xyz"]
  @sha1_string "0ea65fdc73d811ed137f385478285cd146236a06"

  test "the sha hash match the string should return true" do
    assert wechat_sha(@string)
    assert wechat_hash_equal?(@string, @sha1_string)
  end
end
