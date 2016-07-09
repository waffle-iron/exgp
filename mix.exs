defmodule ExGP.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  defp deps do
    [
      {:exgp_proto, github: "pcewing/exgp-proto"},
      {:poolboy, "~> 1.5"},

      # This should be uncommented if ELK logging is enabled.
      #{:logger_logstash_backend, "~> 2.0"}
    ]
  end
end
