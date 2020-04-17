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
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:name, :email, :cpf, :birth_date, :gender, :city, :state, :country])
    |> validate_required([
      :cpf
    ])
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
  end
end
