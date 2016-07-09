defmodule Bouncer.Connection.Listener do
  @name {:global, __MODULE__}

  require Logger

  def start_link(port) do
    Logger.debug "#{__MODULE__} - Listening for connections on port #{port}."
    opts = [port: port]
    {:ok, _} = :ranch.start_listener(:Bouncer, 100, :ranch_tcp, opts, Bouncer.Connection.Worker, [])
  end
end
