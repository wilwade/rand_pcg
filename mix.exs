defmodule RandPCG.Mixfile do
  use Mix.Project

  @version "0.1.2"

  def project do
    [app: :rand_pcg,
     version: @version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps(),

     # Docs
     name: "RandPCG",
     source_url: "https://github.com/wilwade/rand_pcg",
     docs: [main: "RandPCG",
            source_ref: "v#{@version}",
            extras: ["README.md"]]]
  end

  # Configuration for the OTP application
  def application do
    [mod: {RandPCG, []}]
  end

  # Dependencies can be Hex packages:
  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    Elixir implementation of the PCG Random Number Algorithm (http://www.pcg-random.org/)
    """
  end

  defp package do
    [
      maintainers: ["Wil Wade"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/wilwade/rand_pcg"},
    ]
  end
end
