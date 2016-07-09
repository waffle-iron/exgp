defmodule Auth.Server.Handler.Register do
  @moduledoc """
  The `Auth.Server.Handler.Register` module provides the functions necessary for handling register requests.
  """

  require Logger

  alias Auth.Data.AccessLayer, as: DAL

  @doc """
  Processes a register request message.
  """
  def handle(envelope, request) do
    Logger.debug "#{__MODULE__} - handling a register request"
    do_handle(envelope, request)
  end

  defp do_handle(envelope, request) do
    {envelope, request}
    |> do_check_email_availability
    |> do_generate_gid
    |> do_register_account
  end

  defp do_check_email_availability({envelope, request}) do
    case DAL.find_account_by_email(request.email) do
      nil ->
        Logger.debug "#{__MODULE__} - email has not yet been registered"
        {:ok, {envelope, request}}

      _account ->
        Logger.debug "#{__MODULE__} - the email is already registered"
        response = do_create_failure_response(envelope, :EMAIL_TAKEN)
        Util.Messaging.send_message(response)
        {:error, :email_already_registered}
    end
  end

  defp do_generate_gid({:ok, {envelope, request}}) do
    Logger.debug "#{__MODULE__} - generating a GID using the IGN requested"
    gid_num = Util.Random.generate_gid_num
    gid = "#{request.ign}##{gid_num}"

    case DAL.find_account_by_gid(gid) do
      [] ->
        Logger.debug "#{__MODULE__} - the GID #{gid} was generated"
        {:ok, {envelope, request, gid}}

      _ ->
        do_generate_gid({:ok, {envelope, request}})
    end
  end
  defp do_generate_gid({:error, error}), do: {:error, error}

  defp do_register_account({:ok, {envelope, request, gid}}) do
    session_key = SecureRandom.uuid

    case DAL.add_account(request.email, gid, request.pass_hash, session_key) do
      {:ok, model} ->
        response = do_create_success_response(envelope, model)
        Logger.debug "#{__MODULE__} - sending a success register response"
        Util.Messaging.send_message(response)

      {:error, _} ->
        response = do_create_failure_response(envelope, :UNKNOWN_ERROR)
        Logger.debug "#{__MODULE__} - Sending a failure register response"
        Util.Messaging.send_message(response)
    end
  end
  defp do_register_account({:error, error}), do: {:error, error}

  defp do_create_success_response(envelope, model) do
    ExGPProto.Envelope.new(
      transaction: ExGPProto.Transaction.new(id: envelope.transaction.id),
      route: ExGPProto.Route.new(
        source: {
          :source_service_address,
          ExGPProto.ServiceAddress.new(service_id: :AUTH)
        },
        dest: {
          :dest_client_address,
          ExGPProto.ClientAddress.new(gid: model.gid, email: model.email, account_id: model.id, anonymous: false),
        }),
      payload: {
        :auth_payload,
        ExGPProto.AuthPayload.new(
          content: {
            :register_response,
            ExGPProto.RegisterResponse.new(
              success: true,
              account_id: model.id,
              gid: model.gid,
              email: model.email,
              session_key: model.session_key)
          })
        })
  end

  defp do_create_failure_response(envelope, reason) do
    ExGPProto.Envelope.new(
      transaction: ExGPProto.Transaction.new(id: envelope.transaction.id),
      route: ExGPProto.Route.new(
        source: {
          :source_service_address,
          ExGPProto.ServiceAddress.new(service_id: :AUTH)
        },
        dest: {
          :dest_client_address,
          ExGPProto.ClientAddress.new}),
      payload: {
        :auth_payload,
        ExGPProto.AuthPayload.new(
          content: {
            :register_response,
            ExGPProto.RegisterResponse.new(
              success: false,
              error: reason)})})
  end
end
