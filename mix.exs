defmodule Markaby.Mixfile do
  use Mix.Project

  def project do
    [
      app: :markaby,
      version: "0.1.0",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
    ]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.12", only: :dev},
      {:mix_test_watch, "~> 0.2", only: [:dev, :test]},
    ]
  end

  defp description do
    """
    Markaby clone in Elixir.
    """
  end

  defp package do
    [
      name: :markaby,
      files: ["lib", "priv", "mix.exs", "README*", "LICENSE"],
      maintainers: ["Sander Hahn"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/sanderhahn/markaby"},
    ]
  end  
end
