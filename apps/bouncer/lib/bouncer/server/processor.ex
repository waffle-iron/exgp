defmodule Bouncer.Server.Processor do
  @moduledoc """
  TODO
  """

  require Logger
  use Supervisor

  # TODO: These should be defined in config.exs.
  @supervisor_name Bouncer.Server.Processor.Supervisor
  @pool_name :bouncer_pool
  @pool_size 2
  @pool_worker Bouncer.Server.Worker
  @pool_max_overflow 0

  def start_link do
    Logger.debug "Starting #{__MODULE__} with local name #{inspect @supervisor_name}."
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    Logger.debug "#{__MODULE__} was started!"
    poolboy_config = [
      {:name, {:local, @pool_name}},
      {:worker_module, @pool_worker},
      {:size, @pool_size},
      {:max_overflow, @pool_max_overflow}
    ]

    children = [
      :poolboy.child_spec(@pool_name, poolboy_config, [])
    ]

    options = [
      strategy: :one_for_one,
      name: @supervisor_name
    ]

    Logger.debug "Starting a pool of #{@pool_size} #{inspect @pool_worker} children."
    supervise(children, options)
  end

  def process(message) do
    Logger.debug "#{__MODULE__} - Delegating the processing of an bouncer message to the worker pool!"
    spawn(fn -> do_process(message) end)
  end

  defp do_process(message) do
    :poolboy.transaction(
      @pool_name,
      fn(pid) -> Bouncer.Server.Worker.process(pid, message) end,
      :infinity
    )
  end
end
