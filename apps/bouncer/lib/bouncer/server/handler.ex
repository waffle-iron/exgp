defmodule Bouncer.Server.Handler do
  @moduledoc """
  TODO
  """

  require Logger

  alias Bouncer.Connection.Cache

  def handle_message(%{route: %{dest: {:dest_client_address, %{anonymous: true}}}} = message) do
    Logger.debug "#{__MODULE__} - Routing a message to a client."

    #TODO
  end

  @doc """
  This function handles a successful *LoginResponse* message, which is one of the special case messages.
  """
  def handle_message(
    %{
      route: %{dest: {:dest_client_address, _}},
      payload: {:auth_payload, %{content: {:login_response, %{success: true} = response}}},
      transaction: %{id: transaction_id}
    } = message
  ) do
    Logger.debug "#{__MODULE__} - received a successful login response, removing the pending connection"
    connection = Cache.get_pending_connection(transaction_id)
    Cache.remove_pending_connection(transaction_id)

    Logger.debug "#{__MODULE__} - adding the verified connection"
    Cache.add_verified_connection(response.account_id, connection)

    Logger.debug "#{__MODULE__} - forwarding the response to the client"
    data = ExGPProto.Envelope.encode(message)
    connection.socket
    |> connection.transport.send(data)
  end

  @doc """
  This function handles an unsuccessful *LoginResponse* message, which is one of the special case messages.
  """
  def handle_message(
    %{
      route: %{dest: {:dest_client_address, _}},
      payload: {:auth_payload, %{content: {:login_response, %{success: false} = response}}},
      transaction: %{id: transaction_id}
    } = message
  ) do
    Logger.debug "#{__MODULE__} - received an unsuccessful login response, removing the pending connection"
    connection = Cache.get_pending_connection(transaction_id)
    Cache.remove_pending_connection(transaction_id)

    Logger.debug "#{__MODULE__} - forwarding the response to the client"
    data = ExGPProto.Envelope.encode(message)
    connection.socket
    |> connection.transport.send(data)

    Logger.debug "#{__MODULE__} - closing the socket connection"
    connection.socket
    |> connection.transport.close
  end

  @doc """
  This function handles a successful *RegisterResponse* message, which is one of the special case messages.
  """
  def handle_message(
    %{
      route: %{dest: {:dest_client_address, _}},
      payload: {:auth_payload, %{content: {:register_response, %{success: true} = response}}},
      transaction: %{id: transaction_id}
    } = message
  ) do
    Logger.debug "#{__MODULE__} - received a successful register response, removing the pending connection"
    connection = Cache.get_pending_connection(transaction_id)
    Cache.remove_pending_connection(transaction_id)

    Logger.debug "#{__MODULE__} - adding the verified connection"
    Cache.add_verified_connection(response.account_id, connection)

    Logger.debug "#{__MODULE__} - forwarding the response to the client"
    data = ExGPProto.Envelope.encode(message)
    connection.socket
    |> connection.transport.send(data)
  end

  @doc """
  This function handles an unsuccessful *RegisterResponse* message, which is one of the special case messages.
  """
  def handle_message(
    %{
      route: %{dest: {:dest_client_address, _}},
      payload: {:auth_payload, %{content: {:register_response, %{success: false} = response}}},
      transaction: %{id: transaction_id}
    } = message
  ) do
    Logger.debug "#{__MODULE__} - received an unsuccessful register response, removing the pending connection"
    connection = Cache.get_pending_connection(transaction_id)
    Cache.remove_pending_connection(transaction_id)

    Logger.debug "#{__MODULE__} - forwarding the response to the client"
    data = ExGPProto.Envelope.encode(message)
    connection.socket
    |> connection.transport.send(data)

    Logger.debug "#{__MODULE__} - closing the socket connection"
    connection.socket
    |> connection.transport.close
  end

  # Reconnect Response
  def handle_message(
    %{
      route: %{dest: {:dest_client_address, _}},
      payload: {:auth_payload, %{content: {:reconnect_response, response}}}
    } = message
  ) do

  end


  def handle_message(%{route: %{dest: {:dest_service_address, _}}} = message) do
    Logger.debug "#{__MODULE__} - Routing a message to the router."
    Util.Messaging.send_message(message)
    #TODO
  end
end
