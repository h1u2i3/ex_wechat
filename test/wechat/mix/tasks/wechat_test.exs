defmodule Mix.Tasks.WechatTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.Wechat

  @help_message """
  Wechat Quick Command:

  mix wechat            # Print help messasge
  mix wechat.user       # Get user info or list
  mix wechat.gen        # Generate the template file of news or menu
  mix wechat.menu       # Oprater with the wechat menu
  """

  test "should display help message" do
    Wechat.run([])
    assert_received {:mix_shell, :info, [@help_message]}
  end
end
