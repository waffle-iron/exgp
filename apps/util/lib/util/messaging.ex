defmodule Util.Messaging do
  @moduledoc """
  TODO
  """

  def send_message(message) do
    Util.ServiceManifest.get.router
    |> GenServer.cast({:handle_message, message})
  end
end
