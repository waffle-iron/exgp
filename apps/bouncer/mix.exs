defmodule Bouncer.Mixfile do
  use Mix.Project

  def project do
    [app: :bouncer,
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
    [applications: [:logger, :poolboy, :ranch],
     mod: {Bouncer, []}]
  end

  defp deps do
    [
      {:util, in_umbrella: true},
      {:ranch, "~> 1.2"}
    ]
  end
end
