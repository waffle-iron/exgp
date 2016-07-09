defmodule Bouncer.Server.Worker do
  @moduledoc """
  TODO
  """

  use GenServer
  require Logger

  def process(pid, message) do
    GenServer.call(pid, {:process, message})
  end

  ###
  # GenServer API
  ###

  def start_link([]) do
    Logger.debug "Starting #{__MODULE__}."
    GenServer.start_link(__MODULE__, [], [])
  end

  def init(state) do
    Logger.debug "#{__MODULE__} was started with pid #{inspect self}!"
    {:ok, state}
  end

  def handle_call({:process, message}, _from, state) do
    Logger.debug "Process with pid #{inspect self} is processing a bouncer message."
    Bouncer.Server.Handler.handle_message(message)
    {:reply, :ok, state}
  end
end
