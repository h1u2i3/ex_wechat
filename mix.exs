defmodule Wechat.Mixfile do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :ex_wechat,
      version: @version,
      elixir: "~> 1.8",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      docs: [
        extras: ["README.md"],
        main: "readme",
        source_ref: "v#{@version}",
        source_url: "https://github.com/h1u2i3/ex_wechat"
      ]
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
      {:httpoison, "~> 1.5"},
      {:poison, "~> 4.0"},
      {:plug, "~> 1.7"},
      {:floki, "~> 0.20.4"},
      {:dialyxir, "~> 0.5.1", only: [:dev], runtime: false},
      {:ex_doc, github: "elixir-lang/ex_doc", only: :dev},
      {:mix_test_watch, "~> 0.9.0", only: :dev},
      {:excoveralls, "~> 0.10.6", only: :test},
      {:phoenix, "~> 1.4", only: :test}
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
