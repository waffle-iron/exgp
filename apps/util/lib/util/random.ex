defmodule Util.Random do
  @doc """
  Generates a random 4 digit number to be used when generating a GID.

  This is not cryptographically strong but it doesn't need to be.
  """
  def generate_gid_num do
    rem(:rand.uniform(65535), 8999) + 1000
  end

  def generate_guid do
    SecureRandom.uuid
  end
end
