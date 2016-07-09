defmodule Auth do
  use Application

  alias Auth.Data.Repo

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Repo, [[name: Auth.RepoSupervisor]]),
      supervisor(Auth.Server, [])
    ]

    opts = [strategy: :one_for_one, name: Auth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
