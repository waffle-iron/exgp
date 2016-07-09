defmodule Auth.Server do
  @moduledoc """
  TODO
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Auth.Server.Listener, []),
      supervisor(Auth.Server.Processor, [], [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
