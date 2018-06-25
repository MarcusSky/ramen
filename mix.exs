defmodule Ramen.MixProject do
  use Mix.Project

  def project do
    [
      app: :ramen,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :tentacat]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tentacat, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0", override: true}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
