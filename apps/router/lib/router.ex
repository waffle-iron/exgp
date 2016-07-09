defmodule Router do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Router.Server, [])
    ]

    opts = [strategy: :one_for_one, name: Router.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
