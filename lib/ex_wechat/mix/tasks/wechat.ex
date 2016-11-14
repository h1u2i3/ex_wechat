defmodule Mix.Tasks.Wechat do
  use Mix.Task

  def run(args) do
    IO.inspect args
    print_help_message
  end

  defp print_help_message do
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def http do
    quote do
      use Mix.Task

      def run(args) do
        :application.ensure_all_started(:httpoison)
        run_http(args)
      end

      unquote(print)
      unquote(module)
    end
  end

  def base do
    quote do
      use Mix.Task

      unquote(print)
      unquote(module)
    end
  end

  defp module do
    quote do
      defmacro module_get(string) do
        atom_list =
          string
          |> String.split(".")
          |> Enum.map(&String.to_atom/1)
        {:__aliases__, [alias: false], atom_list}
      end
    end
  end

  defp print do
    quote do
      def pp(result) do
        opts = struct(Inspect.Opts, [pretty: true])
        iodata = Inspect.Algebra.format(Inspect.Algebra.to_doc(result, opts), 100)
        IO.puts :stdio, IEx.color(:eval_result, iodata)
      end
    end
  end
end
