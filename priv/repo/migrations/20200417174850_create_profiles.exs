defmodule Bankx.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      add(:email, :string)
      add(:cpf, :string)
      add(:birth_date, :date)
      add(:gender, :string)
      add(:city, :string)
      add(:state, :string)
      add(:country, :string)
      add(:status, :string)

      timestamps()
    end

    create(unique_index(:profiles, [:email]))
    create(unique_index(:profiles, [:cpf]))
  end
end
