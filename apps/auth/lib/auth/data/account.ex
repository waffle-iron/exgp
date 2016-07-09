defmodule Auth.Data.Account do
  use Ecto.Schema

  schema "account" do
    field :gid
    field :email
    field :pass_hash
    field :session_key
  end
end
