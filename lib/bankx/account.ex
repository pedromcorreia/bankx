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

  IF Raises Ecto.Query.CastError, so response will be nil

  ## Examples

      iex> get_profile!(123)
      %Profile{}

      iex> get_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profile(nil), do: nil

  def get_profile(id) do
    result =
      Profile
      |> Repo.get(id)
      |> Repo.preload(:profiles)

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
  rescue
    Ecto.Query.CastError -> nil
  end

  @doc """
  Gets a single profile by referral_code

  ## Examples

      iex> get_profile_by_referral_code(nil)
      nil

      iex> get_profile_by_referral_code(123)
      %Profile{}

      iex> get_profile_by_referral_code(456)
      nil

  """
  def get_profile_by_referral_code(nil), do: nil

  def get_profile_by_referral_code(referral_code) do
    Repo.get_by(Profile, referral_code: referral_code)
  end

  @doc """
  Gets a single profile by cpf

  ## Examples

      iex> get_profile_by_cpf(nil)
      nil

      iex> get_profile_by_cpf(123)
      %Profile{}

      iex> get_profile_by_cpf(456)
      nil

  """
  def get_profile_by_cpf(nil), do: nil

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
    |> Profile.changeset_update(attrs)
    |> Repo.update()
    |> validate_bank_account()
  end

  defp validate_bank_account({:ok, %Profile{} = profile}) do
    profile
    |> Map.drop([:referral_code, :profile_id])
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
