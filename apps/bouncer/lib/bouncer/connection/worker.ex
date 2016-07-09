defmodule Bouncer.Connection.Worker do

  require Logger

  def start_link(ref, socket, transport, opts) do
    pid = spawn_link(__MODULE__, :init, [ref, socket, transport, opts])
    {:ok, pid}
  end

  def init(ref, socket, transport, _opts = []) do
    :ok = :ranch.accept_ack(ref)
    Logger.debug "#{__MODULE__} - a client has connected"
    do_receive_first_message(socket, transport)
  end


  # There are two acceptable cases for the first message a client sends.
  #   1. An anonymous request
  #   2. An authentication request
  #
  # The first case is identifiable as the route's source in the message will be a ClientAddress with the anonymous
  # field set to true. The second case is identifiable as the message's payload will be either a LoginRequest, a
  # RegisterRequest, or a ReconnectRequest.
  defp do_receive_first_message(socket, transport) do
    # Only give the client 2 seconds between connecting to the socket and sending a message before timing out.
    timeout_seconds = 2
    Logger.debug "#{__MODULE__} - waiting for the first message from the client, if the timeout of #{timeout_seconds} seconds is reached, the socket will be closed"
    case transport.recv(socket, 0, timeout_seconds * 1000) do
      {:ok, data} ->
        case do_decode_message(data) do
          {:ok, envelope} -> do_handle_first_message(socket, transport, envelope)
          {:error, _error} -> :ok = transport.close(socket)
        end

      {:error, :timeout} ->
        Logger.debug "#{__MODULE__} - timeout of #{timeout_seconds} seconds was reached while waiting for the first message from the client, closing the socket"
        :ok = transport.close(socket)

      _ ->
        Logger.warn "#{__MODULE__} - an error occurred while receiving the first message from a client"
    end
  end

  # TODO: Case 1
  #defp do_handle_first_message(
  #  socket,
  #  transport,
  #  %{route: %{source: {:source_client_address, %{anonymous: true}, dest: {:dest_service_address, _}}}} = envelope
  #) do
  #end

  # Case 2
  defp do_handle_first_message(
    socket,
    transport,
    %{route: %{dest: {:dest_service_address, %{service_id: :AUTH}}}} = envelope
  ) do
    Logger.debug "#{__MODULE__} - first message from client received, generating a transaction ID"
    transaction_id = Util.Random.generate_guid

    Logger.debug "#{__MODULE__} - adding the pending connection with the transaction ID #{transaction_id}"
    connection = Bouncer.Connection.new(transport, socket)
    Bouncer.Connection.Cache.add_pending_connection(transaction_id, connection)

    Logger.debug "#{__MODULE__} - appending the transaction header to the message."
    transaction = %ExGPProto.Transaction{id: transaction_id}
    envelope = %{envelope | transaction: transaction}

    Logger.debug "#{__MODULE__} - forwarding the message to the routing service."
    Util.Messaging.send_message(envelope)

    do_receive_second_message(socket, transport)
  end

  defp do_receive_second_message(socket, transport) do
    case transport.recv(socket, 0, 15000) do
      {:ok, data} ->
        case do_decode_message(data) do
          {:ok, envelope} -> do_handle_second_message(socket, transport, envelope)
          {:error, _error} -> :ok = transport.close(socket)
        end

      # TODO: Check timeout separately and send a keepalive instead of closing the socket.
      _ ->
        :ok = transport.close(socket)
    end
  end

  # TODO: The account_id field doesn't actually exist in the proto definitions yet.
  defp do_handle_second_message(socket, transport, envelope) do
    %{route: %{source: {:source_client_address, %{account_id: account_id}}}} = envelope

    # Get the verified connection that corresponds to the given account_id. If none exists, close the connection.
    case Bouncer.Connection.Cache.get_verified_connection(account_id) do
      %{socket: cached_socket} ->
        if socket == cached_socket do
          Logger.debug "Forwarding the message to the routing service."
          Util.Messaging.send_message(envelope)

          do_receive_subsequent_message(socket, transport, account_id)
        else
          transport.close(socket)
        end

      nil -> transport.close(socket)
    end
  end

  defp do_receive_subsequent_message(socket, transport, account_id) do
    case transport.recv(socket, 0, 15000) do
      {:ok, data} ->
        case do_decode_message(data) do
          {:ok, envelope} -> do_handle_subsequent_message(socket, transport, envelope, account_id)
          {:error, _error} -> :ok = transport.close(socket)
        end

      # TODO: Check timeout separately and send a keepalive instead of closing the socket.
      _ ->
        :ok = transport.close(socket)
    end
  end

  defp do_handle_subsequent_message(socket, transport, envelope, account_id) do
    %{route: %{source: {:source_client_address, %{account_id: proposed_account_id}}}} = envelope

    # Get the verified connection that corresponds to the given account_id. If none exists, close the connection.
    case proposed_account_id == account_id do
      true ->
        Logger.debug "Forwarding the message to the routing service."
        Util.Messaging.send_message(envelope)

        do_receive_subsequent_message(socket, transport, account_id)

      false ->
        transport.close(socket)
    end
  end

  defp do_decode_message(data) do
    try do
      envelope = ExGPProto.Envelope.decode(data)
      {:ok, envelope}
    rescue
      error in MatchError ->
        Logger.warn "#{__MODULE__} - failed to decode message"
        {:error, error}
    end
  end
end
