defmodule Bouncer.Connection.Manager do
  @moduledoc """
  TODO
  """

  @port 10001

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Bouncer.Connection.Cache, []),
      worker(Bouncer.Connection.Listener, [@port])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
