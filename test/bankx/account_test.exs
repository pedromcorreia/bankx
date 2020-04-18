defmodule Bankx.AccountTest do
  use Bankx.DataCase

  alias Bankx.Account
  alias Bankx.Encryption.{EncryptedField, HashField}

  describe "profiles" do
    alias Bankx.Account.Profile

    @cpf CPF.generate() |> to_string

    @valid_attrs %{
      birth_date: ~D[2010-04-17],
      city: "some city",
      country: "some country",
      cpf: @cpf,
      email: "some@mail.com",
      gender: "some gender",
      name: "some name",
      state: "some state"
    }
    @update_attrs %{
      birth_date: ~D[2011-05-18],
      city: "some updated city",
      country: "some updated country",
      cpf: @cpf,
      email: "someupdate@mail.com",
      gender: "some updated gender",
      name: "some updated name",
      state: "some updated state"
    }
    @invalid_attrs %{
      birth_date: nil,
      city: nil,
      country: nil,
      cpf: nil,
      email: nil,
      gender: nil,
      name: nil,
      state: nil
    }

    def profile_fixture(attrs \\ %{}) do
      {:ok, profile} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_profile()

      profile
    end

    def remove_cpf_hash(profile) do
      {:ok, email} = EncryptedField.load(profile.email)
      {:ok, name} = EncryptedField.load(profile.name)
      {:ok, cpf} = EncryptedField.load(profile.cpf)

      Map.drop(%{profile | email: email, name: name, cpf: cpf}, [:cpf_hash])
    end

    test "get_profile_by_cpf/1 returns the profile with given id" do
      profile = profile_fixture()

      assert Map.drop(Account.get_profile_by_cpf(@cpf), [:cpf_hash]) ==
               remove_cpf_hash(profile)
    end

    test "create_profile/1 with valid data creates a profile" do
      assert {:ok, %Profile{} = profile} = Account.create_profile(@valid_attrs)
      assert profile.birth_date == ~D[2010-04-17]
      assert profile.city == "some city"
      assert profile.country == "some country"
      assert profile.cpf_hash == HashField.hash(@valid_attrs.cpf)
      assert profile.gender == "some gender"
      assert profile.state == "some state"
      assert profile.status == :completed
    end

    test "changeset validates uniqueness of cpf through cpf_hash" do
      Repo.insert!(Profile.changeset(%Profile{}, @valid_attrs))
      {:error, changeset} = Repo.insert(Profile.changeset(%Profile{}, @valid_attrs))
      {:ok, message} = Keyword.fetch(changeset.errors, :cpf_hash)
      msg = List.first(Tuple.to_list(message))
      assert "has already been taken" == msg
    end

    test "create_profile/1 with cpf valid" do
      assert {:ok, %Profile{} = profile} = Account.create_profile(%{cpf: @cpf})
      assert profile.cpf_hash == HashField.hash(@valid_attrs.cpf)
      assert profile.status == :pending
    end

    test "create_profile/1 with cpf and email, status must be pending" do
      assert {:ok, %Profile{} = profile} =
               Account.create_profile(%{cpf: @cpf, email: "email@mail.com"})

      assert profile.cpf_hash == HashField.hash(@valid_attrs.cpf)
      assert profile.status == :pending
    end

    test "create_profile/1 with same cpf and email" do
      assert {:ok, %Profile{} = profile} = Account.create_profile(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Account.create_profile(@valid_attrs)
    end

    test "create_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_profile(@invalid_attrs)
    end

    test "create_profile/1 create then update, turns status" do
      assert {:ok, %Profile{} = profile} = Account.create_profile(%{cpf: @cpf})
      assert profile.cpf_hash == HashField.hash(@valid_attrs.cpf)
      assert profile.status == :pending
      assert {:ok, %Profile{} = profile} = Account.update_profile(profile, @update_attrs)
      assert profile.status == :completed
    end

    test "create_profile/1 create then update some field then complete, turns status" do
      assert {:ok, %Profile{} = profile} = Account.create_profile(%{cpf: @cpf})
      assert profile.cpf_hash == HashField.hash(@valid_attrs.cpf)
      assert profile.status == :pending
      assert {:ok, %Profile{} = profile} = Account.update_profile(profile, %{city: "Brasilia"})
      assert profile.status == :pending
      assert {:ok, %Profile{} = profile} = Account.update_profile(profile, @update_attrs)
      assert profile.status == :completed
    end

    test "update_profile/2 with valid data updates the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{} = profile} = Account.update_profile(profile, @update_attrs)
      assert profile.birth_date == ~D[2011-05-18]
      assert profile.city == "some updated city"
      assert profile.country == "some updated country"
      assert profile.cpf_hash == HashField.hash(@valid_attrs.cpf)
      assert profile.gender == "some updated gender"
      assert profile.state == "some updated state"
      assert profile.status == :completed
    end

    test "update_profile/2 with invalid data returns error changeset" do
      profile = profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_profile(profile, @invalid_attrs)

      assert Map.drop(Account.get_profile_by_cpf(@cpf), [:cpf_hash]) ==
               remove_cpf_hash(profile)
    end

    test "change_profile/1 returns a profile changeset" do
      profile = profile_fixture()
      assert %Ecto.Changeset{} = Account.change_profile(profile)
    end
  end
end
