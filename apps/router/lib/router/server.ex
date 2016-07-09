defmodule Router.Server do
  @moduledoc """
  TODO
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Router.Server.Listener, []),
      supervisor(Router.Server.Processor, [], [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
