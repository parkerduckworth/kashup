defmodule Kashup.MixProject do
  use Mix.Project

  @github_url "https://github.com/parkerduckorth/kashup"

  def project do
    [
      app: :kashup,
      name: "Kashup",
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:disco, :logger, :mnesia],
      mod: {Kashup.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:disco, git: "github.com/parkerduckworth/disco"},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:gen_stage, "~> 1.0"}
    ]
  end

  # Run "mix docs" to generate local documentation files.
  defp docs do
    [
      source_url: @github_url,
      main: "overview",
      extra_section: "guides",
      extras: [
        "docs/overview.md"
      ]
    ]
  end
end
