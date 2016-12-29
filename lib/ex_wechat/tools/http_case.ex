defmodule ExWechat.Tools.HttpCase do
  @moduledoc """
  A module to make test with ExWechat.Http easy
  """

  def fake(response) do
    Application.put_env :ex_wechat, :http_case,
    fn _ -> response end
  end
end
