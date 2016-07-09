defmodule Bouncer.Server do
  @moduledoc """
  TODO
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Bouncer.Server.Listener, []),
      supervisor(Bouncer.Server.Processor, [], [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
