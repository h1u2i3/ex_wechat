defmodule ExWechat.Tools.WechatCase do
  @moduledoc """
  A module to make test with ExWechat.Http easy
  """

  def fake(response) do
    Application.put_env :ex_wechat, :wechat_case,
    fn -> response end
  end
end
