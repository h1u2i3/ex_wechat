defmodule ExWechat.TestCase do
  @moduledoc """
  A module to make test with ExWechat.Http easy
  """

  def fake(response) do
    Application.put_env :ex_wechat, :wechat_case,
    fn -> response end
  end

  def http_fake(response) do
    Application.put_env :ex_wechat, :http_case,
    fn -> response end
  end

  def wechat_site_fake(response) do
    Application.put_env :ex_wechat, :wechat_site_case,
    fn -> response end
  end
end
