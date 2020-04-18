defmodule BankxWeb.ProfileControllerTest do
  use BankxWeb.ConnCase

  alias Bankx.Account
  alias Bankx.Account.Profile

  @cpf CPF.generate() |> to_string()

  @create_attrs %{
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

  def fixture(:profile) do
    {:ok, profile} = Account.create_profile(@create_attrs)
    profile
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "account" do
    test "renders id when data is valid", %{conn: conn} do
      conn = post(conn, Routes.profile_path(conn, :account), profile: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.profile_path(conn, :show, id))

      assert %{
               "id" => id,
               "status" => "completed"
             } = json_response(conn, 200)["data"]
    end

    test "renders status pending when data is valid", %{conn: conn} do
      conn = post(conn, Routes.profile_path(conn, :account), profile: %{cpf: @cpf})
      assert %{"status" => "pending"} = json_response(conn, 201)["data"]

      # this should return on response the pending
      # conn = get(conn, Routes.profile_path(conn, :show, id))

      # assert %{
      #          "id" => id,
      #          "status" => "completed"
      #        } = json_response(conn, 200)["data"]
    end

    test "renders status pending when data is valid, then try update still pending", %{conn: conn} do
      {:ok, profile} = Account.create_profile(%{cpf: @cpf})
      conn = post(conn, Routes.profile_path(conn, :account), profile: %{cpf: @cpf})
      assert %{"status" => "pending"} = json_response(conn, 200)["data"]
    end

    test "renders status pending when data is valid, then try update completed", %{conn: conn} do
      {:ok, profile} = Account.create_profile(%{cpf: @cpf})
      conn = post(conn, Routes.profile_path(conn, :account), profile: @create_attrs)
      assert %{"status" => "completed"} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.profile_path(conn, :account), profile: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when data is empty", %{conn: conn} do
      conn = post(conn, Routes.profile_path(conn, :account), profile: %{})
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_profile(_) do
    profile = fixture(:profile)
    {:ok, profile: profile}
  end
end
