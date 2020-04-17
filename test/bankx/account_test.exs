defmodule Bankx.AccountTest do
  use Bankx.DataCase

  alias Bankx.Account

  describe "profiles" do
    alias Bankx.Account.Profile

    @cpf CPF.generate() |> to_string

    @valid_attrs %{
      birth_date: ~D[2010-04-17],
      city: "some city",
      country: "some country",
      cpf: @cpf,
      email: "some email",
      gender: "some gender",
      name: "some name",
      state: "some state",
      status: "some status"
    }
    @update_attrs %{
      birth_date: ~D[2011-05-18],
      city: "some updated city",
      country: "some updated country",
      cpf: @cpf,
      email: "some updated email",
      gender: "some updated gender",
      name: "some updated name",
      state: "some updated state",
      status: "some updated status"
    }
    @invalid_attrs %{
      birth_date: nil,
      city: nil,
      country: nil,
      cpf: nil,
      email: nil,
      gender: nil,
      name: nil,
      state: nil,
      status: nil
    }

    def profile_fixture(attrs \\ %{}) do
      {:ok, profile} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Account.create_profile()

      profile
    end

    test "list_profiles/0 returns all profiles" do
      profile = profile_fixture()
      assert Account.list_profiles() == [profile]
    end

    test "get_profile!/1 returns the profile with given id" do
      profile = profile_fixture()
      assert Account.get_profile!(profile.id) == profile
    end

    test "create_profile/1 with valid data creates a profile" do
      assert {:ok, %Profile{} = profile} = Account.create_profile(@valid_attrs)
      assert profile.birth_date == ~D[2010-04-17]
      assert profile.city == "some city"
      assert profile.country == "some country"
      assert profile.cpf == @cpf
      assert profile.email == "some email"
      assert profile.gender == "some gender"
      assert profile.name == "some name"
      assert profile.state == "some state"
      assert profile.status == "some status"
    end

    test "create_profile/1 with cpf valid" do
      assert {:ok, %Profile{} = profile} = Account.create_profile(%{cpf: @cpf})
      assert profile.cpf == @cpf
    end

    test "create_profile/1 with same cpf and email" do
      assert {:ok, %Profile{} = profile} = Account.create_profile(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Account.create_profile(@valid_attrs)
    end

    test "create_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_profile(@invalid_attrs)
    end

    test "update_profile/2 with valid data updates the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{} = profile} = Account.update_profile(profile, @update_attrs)
      assert profile.birth_date == ~D[2011-05-18]
      assert profile.city == "some updated city"
      assert profile.country == "some updated country"
      assert profile.cpf == @cpf
      assert profile.email == "some updated email"
      assert profile.gender == "some updated gender"
      assert profile.name == "some updated name"
      assert profile.state == "some updated state"
      assert profile.status == "some updated status"
    end

    test "update_profile/2 with invalid data returns error changeset" do
      profile = profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Account.update_profile(profile, @invalid_attrs)
      assert profile == Account.get_profile!(profile.id)
    end

    test "delete_profile/1 deletes the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{}} = Account.delete_profile(profile)
      assert_raise Ecto.NoResultsError, fn -> Account.get_profile!(profile.id) end
    end

    test "change_profile/1 returns a profile changeset" do
      profile = profile_fixture()
      assert %Ecto.Changeset{} = Account.change_profile(profile)
    end
  end
end
