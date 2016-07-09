defmodule Bouncer.Connection.Cache do
  @moduledoc """
  The `Bouncer.Connection.Cache` module simply holds the open client connections. It consists of two separate maps that hold pending connections and verified connections.

  When a client first connects to the `Bouncer` service's listening socket, assuming the message they send is valid, a transaction ID is generated and is used as the key in the pending connections map. This provides an easy way for another service to respond to whatever the client's request may be.

  If the client is authenticating, once the successful authentication message is received, their pending connection will be "verified", and it will be moved into the verified connections map with the account ID as the key. If the authentication request is a failure, their pending connection will be "rejected", in which case it is removed from the pending connections list.

  If the client was not authenticating, it is assumed they were making a one-time anonymous request, such as checking if an email is already registered, and after the response is sent to the client, the pending connection will be closed.
  """
  @name {:global, __MODULE__}

  def start_link,
    do: Agent.start_link(fn -> %{pending: Map.new, verified: Map.new} end, name: @name)

  def add_pending_connection(transaction_id, %Bouncer.Connection{} = connection),
    do: Agent.update(@name, &(%{&1 | pending: Map.put(&1.pending, transaction_id, connection)}))

  def get_pending_connection(transaction_id),
    do: Agent.get(@name, &(Map.get(&1.pending, transaction_id)))

  def remove_pending_connection(transaction_id),
    do: Agent.update(@name, &(%{&1 | pending: Map.delete(&1.pending, transaction_id), verified: &1.verified}))

  def add_verified_connection(account_id, connection),
    do: Agent.update(@name, &(%{&1 | verified: Map.put(&1.verified, account_id, connection)}))

  def get_verified_connection(account_id),
    do: Agent.get(@name, &(Map.get(&1.verified, account_id)))

  def remove_verified_connection(account_id),
    do: Agent.update(@name, &(%{&1 | pending: &1.pending, verified: Map.delete(&1.verified, account_id)}))

  def list_pending_connections,
    do: Agent.get(@name, &(Map.keys(&1.pending)))

  def list_verified_connections,
    do: Agent.get(@name, &(Map.keys(&1.verified)))
end
