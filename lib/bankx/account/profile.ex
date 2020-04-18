defmodule Bankx.Account.Profile do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bankx.Encryption.{EncryptedField, HashField}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "profiles" do
    field :birth_date, EncryptedField
    field :city, :string
    field :country, :string
    field :cpf_hash, HashField
    field :cpf, EncryptedField
    field :email, EncryptedField
    field :gender, :string
    field :name, EncryptedField
    field :state, :string
    field :referral_code, :string
    field :status, StatusEnum, default: :pending

    timestamps()
  end

  @params [:birth_date, :city, :country, :cpf, :email, :gender, :name, :state]

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
    |> encrypt_fields
  end

  @doc false
  def changeset_completed(profile) do
    {referral_code, _} = String.split_at(profile.id, 8)

    profile
    |> cast(%{status: :completed, referral_code: referral_code}, [:status, :referral_code])
  end

  defp encrypt_fields(changeset) do
    case changeset.valid? do
      true ->
        {:ok, encrypted_birth_date} = EncryptedField.dump(get_field(changeset, :birth_date))
        {:ok, encrypted_email} = EncryptedField.dump(get_field(changeset, :email))
        {:ok, encrypted_name} = EncryptedField.dump(get_field(changeset, :name))
        {:ok, encrypted_cpf} = EncryptedField.dump(get_field(changeset, :cpf))

        changeset
        |> put_change(:birth_date, encrypted_birth_date)
        |> put_change(:email, encrypted_email)
        |> put_change(:name, encrypted_name)
        |> put_change(:cpf, encrypted_cpf)

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
end
