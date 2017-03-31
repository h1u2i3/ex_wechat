defmodule Wechat.Mixfile do
  use Mix.Project

  @version "0.1.7"

  def project do
    [
      app: :ex_wechat,
      version: @version,
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: [plt_add_apps: [:iex, :mix, :eex, :plug, :poison],
                 paths: ["_build/dev/lib/ex_wechat/ebin"]],
      preferred_cli_env: ["coveralls": :test,
                          "coveralls.detail": :test,
                          "coveralls.post": :test,
                          "coveralls.html": :test],
      docs: [extras: ["README.md"], main: "readme",
       source_ref: "v#{@version}",
       source_url: "https://github.com/h1u2i3/ex_wechat"]
     ]
  end

  def application do
    [
      mod: {Wechat, []},
      extra_applications: [:logger, :httpoison, :floki]
    ]
  end

  defp description do
    """
    A Phoenix/Elixir Wechat Api.
    """
  end

  defp deps do
    [
      {:httpoison, "~> 0.11.1"},
      {:poison, "~> 2.0"},
      {:plug, "~> 1.3"},
      {:floki, "~> 0.15.0"},

      {:dialyxir, "~> 0.4", only: [:dev], runtime: false},
      {:ex_doc, github: "elixir-lang/ex_doc", only: :dev},
      {:mix_test_watch, "~> 0.2", only: :dev},
      {:dogma, "~> 0.1.14", only: :dev},

      {:excoveralls, "~> 0.5.7", only: :test},
      {:phoenix, "~> 1.2.1", only: :test}
    ]
  end

  defp package do
    [
      name: :ex_wechat,
      maintainers: ["h1u2i3"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/h1u2i3/ex_wechat"}
    ]
  end
end
