defmodule Mix.Tasks.Wechat do
  @moduledoc false
  use Mix.Task

  def run(_args) do
    print_help_message()
  end

  defp print_help_message do
    Mix.shell().info("""
    Wechat Quick Command:

    mix wechat            # Print help messasge
    mix wechat.user       # Get user info or list
    mix wechat.gen        # Generate the template file of news or menu
    mix wechat.menu       # Oprater with the wechat menu
    """)
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def http do
    quote do
      use Mix.Task
      import Mix.Generator

      def run(args) do
        :application.ensure_all_started(:httpoison)
        run_http(args)
      end

      unquote(methods())
    end
  end

  def base do
    quote do
      use Mix.Task
      import Mix.Generator

      unquote(methods())
    end
  end

  defp methods do
    quote do
      def module_get(string) do
        string
        |> String.split(".")
        |> Enum.map(&String.to_atom/1)
        |> Module.concat()
      end

      def pp(result) do
        opts = struct(Inspect.Opts, pretty: true)
        iodata = Inspect.Algebra.format(Inspect.Algebra.to_doc(result, opts), 100)
        IO.puts(:stdio, IEx.color(:eval_result, iodata))
      end

      def parse_args(args) do
        {options, _, _} = OptionParser.parse(args, aliases: [h: :help, a: :api])
        options
      end

      def app_dir do
        Application.app_dir(:ex_wechat)
      end
    end
  end
end
