defmodule Bankx.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :binary)
      add(:email, :binary)
      add(:cpf, :binary)
      add(:cpf_hash, :binary)
      add(:birth_date, :binary)
      add(:gender, :string)
      add(:city, :string)
      add(:state, :string)
      add(:country, :string)
      add(:status, :string)
      add(:referral_code, :string)

      timestamps()
    end

    create(unique_index(:profiles, [:email]))
    create(unique_index(:profiles, [:cpf_hash]))
  end
end
