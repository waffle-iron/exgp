defmodule Auth.Server.Handler do
  @moduledoc """
  TODO
  """

  alias Auth.Server.Handler.Login
  alias Auth.Server.Handler.Register

  def handle_message(%{route: %{dest: {:dest_service_address, %{service_id: :AUTH}}}, payload: payload} = message) do
    case payload do
      {:auth_payload, %{content: {:login_request, request}}} ->
        Login.handle(message, request)

      {:auth_payload, %{content: {:register_request, request}}} ->
        Register.handle(message, request)
    end
  end
end
