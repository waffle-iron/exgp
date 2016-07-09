defmodule Auth.Mixfile do
  use Mix.Project

  def project do
    [app: :auth,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :poolboy, :ecto, :postgrex],
     mod: {Auth, []}]
  end

  defp deps do
    [
      {:util, in_umbrella: true},
      {:ecto, "~> 2.0.0-rc.5"},
      {:postgrex, "~> 0.11.1"}
    ]
  end
end
