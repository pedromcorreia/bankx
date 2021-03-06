defmodule Bankx.Encryption.HashField do
  @behaviour Ecto.Type

  @moduledoc """
  This is a module that encode and decode crypto fields
  """

  def type, do: :binary

  def cast(value) do
    {:ok, to_string(value)}
  end

  def dump(value) do
    {:ok, hash(value)}
  end

  def load(value) do
    {:ok, value}
  end

  def embed_as(_), do: :self

  def equal?(value1, value2), do: value1 == value2

  def hash(value) do
    :crypto.hash(:sha256, value <> get_salt(value))
  end

  # Get/use Phoenix secret_key_base as "salt" for one-way hashing Email address
  # use the *value* to create a *unique* "salt" for each value that is hashed:
  defp get_salt(value) do
    :crypto.hash(:sha256, value <> key())
  end

  defp key do
    Base.decode64!("AxZMGDgP0bt8MXcn7issnWMsQPxgutYHME8DKA7V7uI=")
  end
end
