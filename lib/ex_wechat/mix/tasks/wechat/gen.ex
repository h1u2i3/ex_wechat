defmodule Mix.Tasks.Wechat.Gen do
  use Mix.Tasks.Wechat, :base

  def run(_) do
    Mix.shell.info """
    # Generate the wechat need file.

    mix wechat.gen.menu         Generate the menu in root folder
      --name NAME                 Filename of file
    mix wechat.gen.news         Generate the news in root folder
      --name NAME                 Filename of file
    """
  end

  defmodule Menu do
    use Mix.Tasks.Wechat, :base

    def run(args) do
      options = parse_args(args)
      name = options[:name] || "menu"
      path = "#{File.cwd!}/menus"

      create_directory path
      create_file("#{path}/#{name}.exs",
        File.read!(Path.join(__DIR__, "../templates/menu.exs")))
    end
  end

  defmodule New do
    use Mix.Tasks.Wechat, :base

    def run(args) do
      options = parse_args(args)
      name = options[:name] || "new"
      path = "#{File.cwd!}/news"

      create_directory path
      create_file("#{path}/#{name}.exs",
        File.read!(Path.join(__DIR__, "../templates/new.exs")))
    end
  end
end
