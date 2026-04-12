defmodule Refmon.MixProject do
  use Mix.Project
  @description """
  Refmon is an Elixir implementation of a reference monitor.
  """
  def project do
    [
      app: :refmon,
      name: "Refmon",
      description: @description,
      version: "0.1.2",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Refmon.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:cachex, "~> 4.1"},
      {:ex_doc, "~> 0.40.1", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18.5", only: :test},
      {:mix_version, "~> 2.4.0", only: [:dev, :test], runtime: false},
    ]
  end

  # Add extra modules for test
  defp elixirc_paths(:test), do: ["lib", "test/extras"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      maintainers: ["Kenta Hattori"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/khattori/refmon"}
    ]
  end
end
