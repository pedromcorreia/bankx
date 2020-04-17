defmodule Bankx.Account.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "profiles" do
    field :birth_date, :date
    field :city, :string
    field :country, :string
    field :cpf, :string
    field :email, :string
    field :gender, :string
    field :name, :string
    field :state, :string
    field :status, StatusEnum, default: :pending

    timestamps()
  end

  @params [:birth_date, :city, :country, :cpf, :email, :gender, :name, :state]

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, @params)
    |> validate_required([
      :cpf
    ])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> unique_constraint(:cpf)
    |> CPF.Ecto.Changeset.validate_cpf(:cpf)
    |> Ecto.Changeset.prepare_changes(fn changeset ->
      if input = Ecto.Changeset.get_change(changeset, :cpf) do
        string_cpf = input |> CPF.parse!() |> to_string()
        Ecto.Changeset.put_change(changeset, :cpf, string_cpf)
      else
        changeset
      end
    end)
    |> validate_bank_account()
  end

  defp validate_bank_account(%Ecto.Changeset{} = changeset) do
    value = Map.get(changeset.changes, :status)

    case StatusEnum.equal?(:pending, value) or is_nil(value) do
      true ->
        check_completed(changeset)

      false ->
        add_error(changeset, :invite, "invalid invite code")
    end
  end

  defp check_completed(%Ecto.Changeset{changes: changes} = changeset) when is_map(changes) do
    case @params == Map.keys(changes) do
      true -> Ecto.Changeset.put_change(changeset, :status, :completed)
      _ -> changeset
    end
  end
end
