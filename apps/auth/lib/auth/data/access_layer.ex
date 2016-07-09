defmodule Auth.Data.AccessLayer do
  @moduledoc """
  The auth database provides a DAL module for the processor to use.
  """
  require Logger

  import Ecto.Query

  alias Auth.Data.Account
  alias Auth.Data.Repo

  def find_account_by_email(email) do
    Repo.get_by(Account, email: String.downcase(email))
  end

  def find_account_by_gid(gid) do
    query = from a in Account,
            where: a.gid == ^gid,
            select: a
    Repo.all(query)
  end

  def add_account(email, gid, pass_hash, session_key) do
    account = %Account{
      gid: gid,
      email: String.downcase(email),
      pass_hash: pass_hash,
      session_key: session_key
    }

    Logger.debug "Auth.Database.add_account - Adding account to database. $Account{gamer_id: #{gid}, email: #{email}, pass_hash: #{pass_hash}, session_key: #{session_key}}"

    case Repo.insert account do
      {:ok, model} -> {:ok, model}
      {:error, changeset} ->
        Logger.warn "Auth.Database.add_account - Failed to add the account."
        {:error, :failed_to_add_account}
    end
  end
end
