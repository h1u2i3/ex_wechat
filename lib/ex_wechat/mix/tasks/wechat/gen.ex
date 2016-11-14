defmodule Mix.Tasks.Wechat.Gen do
  use Mix.Tasks.Wechat, :base

  def run(_) do
    Mix.shell.info """
    # Generate the wechat need file.

    mix wechat.gen.menu         # Generate the menu
    mix wechat.gen.news         # Generate the news
    """
  end

  defmodule Menu do
    use Mix.Tasks.Wechat, :base

    def run(_) do  
    end
  end
end
