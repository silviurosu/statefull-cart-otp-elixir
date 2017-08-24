defmodule CartStatefull.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :cart_statefull,
     version: @version,
     elixir: "~> 1.5.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {CartStatefull.Application, []}]
  end

  defp deps do
    [
      {:uuid, ">= 1.1.7"}
    ]
  end
end
