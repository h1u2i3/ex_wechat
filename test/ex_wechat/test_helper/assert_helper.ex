defmodule ExWechat.TestHelper.AssertHelper do
  use ExUnit.Case
  
  def assert_equal_string(first, second) do
    assert String.replace(first, ~r/\s|\n/, "") == String.replace(second, ~r/\s|\n/, "")
  end
end
