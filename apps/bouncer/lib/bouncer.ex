defmodule Bouncer do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Bouncer.Server, []),
      supervisor(Bouncer.Connection.Manager, [])
    ]

    opts = [strategy: :one_for_one, name: Bouncer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
