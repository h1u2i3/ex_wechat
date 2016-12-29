defmodule ExWechat.TestHelper.Http do
  @moduledoc """
    Http mock expect method.
  """

  @doc """
  Make the http request return with the result
  """
  def expect_response(url, params, result) do
    ExWechat.Tools.HttpCase.set(url, params, result)
  end

  @doc """
  Clean http test case cache
  """
  def clean_test_case() do
    ExWechat.Tools.HttpCase.clean()
  end
end
