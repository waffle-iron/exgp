defmodule Router.Server.Handler do
  @moduledoc """
  TODO
  """

  def handle_message(%{route: %{dest: {:dest_client_address, _}}} = message), do:
    Util.ServiceManifest.get.bouncer |> GenServer.cast({:handle_message, message})

  def handle_message(%{route: %{dest: {:dest_service_address, %{service_id: service_id}}}} = message) do
    case service_id do
      :AUTH     -> Util.ServiceManifest.get.auth |> GenServer.cast({:handle_message, message})
      :FRIENDS  -> Util.ServiceManifest.get.friends |> GenServer.cast({:handle_message, message})
      :CHAT     -> Util.ServiceManifest.get.chat |> GenServer.cast({:handle_message, message})
      :BOUNCER  -> Util.ServiceManifest.get.bouncer |> GenServer.cast({:handle_message, message})
    end
  end
end
