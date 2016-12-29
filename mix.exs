defmodule ExWechat.Mixfile do
  use Mix.Project

  @version "0.1.6"

  def project do
    [
      app: :ex_wechat,
      version: @version,
      elixir: "~> 1.3",
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

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      mod: {ExWechat, []},
      applications: [:logger, :httpoison, :floki]
    ]
  end

  defp description do
    """
    A Phoenix/Elixir Wechat Api.
    """
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.9.0"},
      {:poison, "~> 2.0"},
      {:plug, "~> 1.2.2"},
      {:floki, "~> 0.11.0"},

      {:dialyxir, "~> 0.4", only: [:dev], runtime: false},
      {:ex_doc, github: "elixir-lang/ex_doc", only: :dev},
      {:mix_test_watch, "~> 0.2", only: :dev},
      {:dogma, "~> 0.1", only: :dev},

      {:meck, "~> 0.8.2", only: :test},
      {:excoveralls, "~> 0.5", only: :test},
      {:phoenix, "~> 1.2.1", only: :test},
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
