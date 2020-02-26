defmodule TicTac.MixProject do
  use Mix.Project

  def project do
    [
      app: :tic_tac,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TicTac.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
       { :elixir_uuid, "~> 1.2" },
    ]
  end
end
