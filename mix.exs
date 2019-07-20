defmodule Diet.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp releases do
    [
      diet: [
        version: "0.0.1",
        include_executables_for: [:unix],
        applications: [
          diet_web: :permanent,
          runtime_tools: :permanent
        ]
      ]
    ]
  end
end
