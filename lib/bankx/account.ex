defmodule Bankx.Account do
  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false
  alias Bankx.Repo
  alias Bankx.Encryption.{EncryptedField, HashField}
  alias Bankx.Account.Profile

  @doc """
  Gets a single profile.

  Raises `Ecto.NoResultsError` if the Profile does not exist.

  ## Examples

      iex> get_profile!(123)
      %Profile{}

      iex> get_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profile!(id), do: Repo.get!(Profile, id)

  @doc """
  Gets a single profile.

  Raises `Ecto.NoResultsError` if the Profile does not exist.

  ## Examples

      iex> get_profile!(123)
      %Profile{}

      iex> get_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profile_by_cpf(cpf) when is_nil(cpf), do: nil

  def get_profile_by_cpf(cpf) do
    result = Repo.get_by(Profile, cpf_hash: HashField.hash(cpf))

    case result do
      nil ->
        nil

      _ ->
        profile =
          %Profile{
            name: name,
            email: email,
            cpf: cpf,
            birth_date: birth_date
          } = result

        {:ok, email} = EncryptedField.load(email)
        {:ok, name} = EncryptedField.load(name)
        {:ok, cpf} = EncryptedField.load(cpf)
        {:ok, birth_date} = EncryptedField.load(birth_date)

        %{
          profile
          | email: email,
            name: name,
            cpf: cpf,
            birth_date: birth_date
        }
    end
  end

  @doc """
  Creates a profile.

  ## Examples

      iex> create_profile(%{field: value})
      {:ok, %Profile{}}

      iex> create_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_profile(attrs \\ %{}) do
    %Profile{}
    |> Profile.changeset(attrs)
    |> Repo.insert()
    |> validate_bank_account()
  end

  @doc """
  Updates a profile.

  ## Examples

      iex> update_profile(profile, %{field: new_value})
      {:ok, %Profile{}}

      iex> update_profile(profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
    |> validate_bank_account()
  end

  @doc """
  Deletes a profile.

  ## Examples

      iex> delete_profile(profile)
      {:ok, %Profile{}}

      iex> delete_profile(profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_profile(%Profile{} = profile) do
    Repo.delete(profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile changes.

  ## Examples

      iex> change_profile(profile)
      %Ecto.Changeset{source: %Profile{}}

  """
  def change_profile(%Profile{} = profile) do
    Profile.changeset(profile, %{})
  end

  defp validate_bank_account({:ok, %Profile{} = profile}) do
    profile
    |> Map.delete(:referral_code)
    |> Map.values()
    |> Enum.filter(&(!&1))
    |> Enum.empty?()
    |> case do
      true ->
        update_profile_completed(profile)

      _ ->
        {:ok, profile}
    end
  end

  defp validate_bank_account(profile), do: profile

  defp update_profile_completed(%Profile{} = profile) do
    profile
    |> Profile.changeset_completed()
    |> Repo.update()
  end
end
