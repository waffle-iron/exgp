defmodule Auth.Server.Handler.Login do
  @moduledoc """
  The `Auth.Server.Handler.Login` module provides the functions necessary for handling login requests.
  """

  require Logger

  alias Auth.Data.AccessLayer, as: DAL
  alias Auth.Data.Repo

  @doc """
  Handles a login request.
  """
  def handle(envelope, request) do
    Logger.debug "#{__MODULE__} - Handling a login request!"
    do_handle(envelope, request)
  end

  defp do_handle(envelope, request) when not is_nil(request) do
    {envelope, request}
      |> do_find_account
      |> do_check_passhash
      |> do_update_session_key
      |> do_send_success_response
  end

  defp do_find_account({envelope, request}) do
    Logger.debug "#{__MODULE__} - Checking the database for an account with email = #{request.email}"
    case DAL.find_account_by_email(request.email) do
      account when not is_nil(account) ->
        Logger.debug "#{__MODULE__} - An account was found in the database with email = #{request.email}"
        {:ok, {envelope, request, account}}

      nil ->
        Logger.debug "#{__MODULE__} - No account found in the database with email = #{request.email}"
        response = do_create_failure_response(envelope, request, :EMAIL_NOT_REGISTERED)
        Util.Messaging.send_message(response)
        {:error, :account_not_found}
    end
  end

  defp do_check_passhash({:ok, {envelope, request, account}}) do
    Logger.debug "#{__MODULE__} - Checking if the password hash provided matches the value in the database."
    unless String.strip(account.pass_hash) != String.strip(request.pass_hash) do
      Logger.debug "#{__MODULE__} - The password hash provided was correct."
      {:ok, {envelope, request, account}}
    else
      Logger.debug "#{__MODULE__} - Invalid password provided."
      response = do_create_failure_response(envelope, request, :INVALID_PASSWORD)
      Util.Messaging.send_message(response)
      {:error, :invalid_password}
    end
  end
  defp do_check_passhash({:error, error}), do: {:error, error}

  defp do_update_session_key({:ok, {envelope, request, account}}) do
    Logger.debug "#{__MODULE__} - Updating the user's session key."
    session_key = SecureRandom.uuid
    changset = Ecto.Changeset.change account, session_key: session_key

    case Repo.update changset do
      {:ok, model} ->
        {:ok, {envelope, request, model}}

      {:error, _changeset} ->
        Logger.warn "#{__MODULE__} - Failed to update the user's session key."
        response = do_create_failure_response(envelope, request, :SESSION_KEY_FAILURE)
        Util.Messaging.send_message(response)
        {:error, :session_key_failure}
    end
  end
  defp do_update_session_key({:error, error}), do: {:error, error}

  defp do_send_success_response({:ok, {envelope, request, model}}) do
    response = do_create_success_response(envelope, model)
    Logger.debug "#{__MODULE__} - Sending the success response: #{inspect response}"
    Util.Messaging.send_message(response)
    {:ok, {request, model}}
  end
  defp do_send_success_response({:error, error}), do: {:error, error}

  defp do_create_success_response(envelope, model) do
    ExGPProto.Envelope.new(
      transaction: ExGPProto.Transaction.new(id: envelope.transaction.id),
      route: ExGPProto.Route.new(
        source: {
          :source_service_address,
          ExGPProto.ServiceAddress.new(servide_id: :AUTH)
        },
        dest: {
          :dest_client_address,
          ExGPProto.ClientAddress.new(gid: model.gid, email: model.email, account_id: model.id, anonymous: false)}),
      payload: {
        :auth_payload,
        ExGPProto.AuthPayload.new(
          content: {
            :login_response,
            ExGPProto.LoginResponse.new(
              success: true,
              account_id: model.id,
              gid: model.gid,
              email: model.email,
              session_key: model.session_key)})})
  end

  defp do_create_failure_response(envelope, request, reason) do
    ExGPProto.Envelope.new(
      transaction: ExGPProto.Transaction.new(id: envelope.transaction.id),
      route: ExGPProto.Route.new(
        dest: {
          :dest_client_address,
          ExGPProto.ClientAddress.new}),
      payload: {
        :auth_payload,
        ExGPProto.AuthPayload.new(
          content: {
            :login_response,
            ExGPProto.LoginResponse.new(
              success: false,
              error: reason,
              email: request.email)})})
  end
end
