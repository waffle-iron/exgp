defmodule Router.Server.Listener do
  @moduledoc """
  TODO
  """

  use GenServer
  require Logger

  @name Util.ServiceManifest.get.router

  ###
  # GenServer API
  ###

  def start_link do
    Logger.debug "Starting #{__MODULE__} with global name #{inspect @name}."
    GenServer.start_link(__MODULE__, nil, [name: @name])
  end

  def init(state) do
    Logger.debug "#{__MODULE__} was started!"
    {:ok, state}
  end

  def handle_cast({:handle_message, message}, state) do
    Router.Server.Processor.process(message)
    {:noreply, state}
  end
end
