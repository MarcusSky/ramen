defmodule Ramen.MixProject do
  use Mix.Project

  def project do
    [
      app: :ramen,
      version: "0.1.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"},
      {:focus, "~> 0.3.5"},
      {:ex_doc, ">= 0.0.0", only: :dev}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description() do
    "A Richer GitHub API Client."
  end

  defp package() do
    [
      maintainers: ["Marcus Bruno Vieira"],
      name: "ramen",
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/MarcusSky/ramen"}
    ]
  end
end
