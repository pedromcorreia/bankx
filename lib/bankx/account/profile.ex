defmodule Bankx.Account.Profile do
  @moduledoc """
  Profile Schema
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Bankx.Account
  alias Bankx.Account.Profile
  alias Bankx.Encryption.{EncryptedField, HashField}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type Ecto.UUID
  @derive {Phoenix.Param, key: :id}
  schema "profiles" do
    field :birth_date, EncryptedField
    field :city, :string
    field :country, :string
    field :cpf_hash, HashField
    field :cpf, EncryptedField
    field :email, EncryptedField
    field :gender, GenderEnum
    field :name, EncryptedField
    field :state, :string
    field :referral_code, :string
    field :status, StatusEnum, default: :pending

    belongs_to :profile, Profile
    has_many :profiles, Profile

    timestamps()
  end

  @params [
    :birth_date,
    :city,
    :country,
    :cpf,
    :email,
    :gender,
    :name,
    :state,
    :referral_code
  ]

  @update_params [:birth_date, :city, :country, :email, :gender, :name, :state]

  @doc false
  def changeset(profile, attrs) do
    profile
    |> Map.merge(attrs)
    |> cast(attrs, @params)
    |> CPF.Ecto.Changeset.validate_cpf(:cpf)
    |> validate_required([
      :cpf
    ])
    |> validate_format(:email, ~r/@/)
    |> set_hashed_fields
    |> unique_constraint(:cpf_hash)
    |> set_indicator
    |> encrypt_fields
  end

  @doc false
  def changeset_update(profile, attrs) do
    profile
    |> Map.merge(attrs)
    |> cast(attrs, @update_params)
    |> CPF.Ecto.Changeset.validate_cpf(:cpf)
    |> validate_required([
      :cpf
    ])
    |> validate_format(:email, ~r/@/)
    |> set_hashed_fields
    |> unique_constraint(:cpf_hash)
    |> encrypt_fields
  end

  @doc false
  def changeset_completed(profile) do
    {referral_code, _} = String.split_at(profile.id, 8)

    profile
    |> cast(%{status: :completed, referral_code: referral_code}, [
      :status,
      :referral_code
    ])
  end

  defp encrypt_fields(changeset) do
    case changeset.valid? do
      true ->
        {:ok, encrypted_birth_date} =
          EncryptedField.dump(get_field(changeset, :birth_date))

        {:ok, encrypted_cpf} = EncryptedField.dump(get_field(changeset, :cpf))

        {:ok, encrypted_email} =
          EncryptedField.dump(get_field(changeset, :email))

        {:ok, encrypted_name} = EncryptedField.dump(get_field(changeset, :name))

        changeset
        |> put_change(:birth_date, encrypted_birth_date)
        |> put_change(:cpf, encrypted_cpf)
        |> put_change(:email, encrypted_email)
        |> put_change(:name, encrypted_name)

      _ ->
        changeset
    end
  end

  defp set_hashed_fields(changeset) do
    case changeset.valid? do
      true ->
        changeset
        |> put_change(:cpf_hash, HashField.hash(get_field(changeset, :cpf)))

      _ ->
        changeset
    end
  end

  defp set_indicator(changeset) do
    case changeset.valid? && !is_nil(get_field(changeset, :referral_code)) do
      true ->
        profile =
          Account.get_profile_by_referral_code(
            get_field(changeset, :referral_code)
          )

        changeset
        |> put_change(:profile_id, profile.id)

      _ ->
        changeset
    end
  end
end
