use Mix.Config

config :auth, ecto_repos: [Auth.Data.Repo]

config :auth, Auth.Data.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "exgpdb",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"
