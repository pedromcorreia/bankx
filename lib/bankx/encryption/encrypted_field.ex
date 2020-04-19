defmodule Bankx.Encryption.EncryptedField do
  alias Bankx.Encryption.AES

  @moduledoc """
  This is a module use AES do Encrypt fields
  """

  @behaviour Ecto.Type
  def type, do: :binary

  def cast(value) do
    {:ok, to_string(value)}
  end

  def dump(value) do
    ciphertext = value |> to_string |> AES.encrypt()
    {:ok, ciphertext}
  end

  def load(value) do
    {:ok, AES.decrypt(value)}
  end

  def embed_as(_), do: :self

  def equal?(value1, value2), do: value1 == value2
end
