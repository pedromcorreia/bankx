defmodule BankxWeb.ProfileControllerTest do
  use BankxWeb.ConnCase

  alias Bankx.Account
  alias Bankx.Account.Profile
  alias Bankx.Encryption.EncryptedField

  @cpf CPF.generate() |> to_string()

  @create_attrs %{
    birth_date: ~D[2010-04-17],
    city: "some city",
    country: "some country",
    cpf: @cpf,
    email: "some@mail.com",
    gender: "male",
    name: "some name",
    state: "some state",
    referral_code: ""
  }
  @create_attrs_indicator %{
    birth_date: ~D[2010-04-17],
    city: "some city",
    country: "some country",
    cpf: CPF.generate() |> to_string(),
    email: "some_indicator@mail.com",
    gender: "female",
    name: "some name",
    state: "some state"
  }
  @increate_attrs %{
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

  def token(profile) do
    {:ok, cpf} = EncryptedField.load(profile.cpf)

    conn =
      get(build_conn(), Routes.profile_path(build_conn(), :sign_in, profile), %{
        cpf: cpf
      })

    %{
      "token" => token
    } = json_response(conn, 200)["data"]

    token
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "account" do
    test "renders referral_code when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.profile_path(conn, :account), profile: @create_attrs)

      assert %{"referral_code" => referral_code} =
               json_response(conn, 201)["data"]

      profile = Bankx.Repo.one(Profile)

      conn =
        build_conn()
        |> put_req_header("authorization", "bearer: " <> token(profile))
        |> get(Routes.profile_path(conn, :indications))

      assert %{
               "indications" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders referral_code when data is valid with referral_code", %{
      conn: conn
    } do
      {:ok, profile_indicator} = Account.create_profile(@create_attrs_indicator)

      conn =
        post(conn, Routes.profile_path(conn, :account),
          profile: %{
            @create_attrs
            | referral_code: profile_indicator.referral_code
          }
        )

      assert %{"referral_code" => referral_code} =
               json_response(conn, 201)["data"]
    end

    test "renders status pending when data is valid, then try update still pending",
         %{conn: conn} do
      {:ok, _profile} =
        Account.create_profile(%{cpf: @cpf, email: @create_attrs.email})

      conn =
        post(conn, Routes.profile_path(conn, :account), profile: %{cpf: @cpf})

      assert %{"status" => "pending"} = json_response(conn, 200)["data"]
    end

    test "renders status pending when data is valid, then try update completed",
         %{conn: conn} do
      {:ok, _profile} =
        Account.create_profile(%{cpf: @cpf, email: @create_attrs.email})

      conn =
        post(conn, Routes.profile_path(conn, :account), profile: @create_attrs)

      assert %{"status" => "completed"} = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.profile_path(conn, :account), profile: @increate_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when data is empty", %{conn: conn} do
      conn = post(conn, Routes.profile_path(conn, :account), profile: %{})
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "render code pending account when account pending", %{conn: conn} do
      {:ok, %Profile{} = profile} =
        Account.create_profile(%{cpf: @cpf, email: @create_attrs.email})

      conn =
        build_conn()
        |> put_req_header("authorization", "bearer: " <> token(profile))
        |> get(Routes.profile_path(conn, :indications))

      assert %{
               "status" => "pending"
             } = json_response(conn, 200)["data"]
    end

    test "render code pending account when account completed whitout indication",
         %{conn: conn} do
      {:ok, %Profile{referral_code: _referral_code} = profile} =
        Account.create_profile(@create_attrs)

      conn =
        build_conn()
        |> put_req_header("authorization", "bearer: " <> token(profile))
        |> get(Routes.profile_path(conn, :indications))

      assert %{
               "indications" => []
             } = json_response(conn, 200)["data"]
    end

    test "render authorized",
         %{conn: conn} do
      {:ok, %Profile{referral_code: _referral_code} = profile} =
        Account.create_profile(@create_attrs)

      conn =
        get(conn, Routes.profile_path(conn, :sign_in, profile),
          cpf: @create_attrs.cpf
        )

      assert %{
               "token" => _
             } = json_response(conn, 200)["data"]

      assert conn.status == 200
    end

    test "render code pending account when account completed with indications",
         %{conn: conn} do
      {:ok, %Profile{referral_code: referral_code} = profile} =
        Account.create_profile(@create_attrs_indicator)

      {:ok, %Profile{id: _indication_id} = indication} =
        Account.create_profile(%{@create_attrs | referral_code: referral_code})

      conn =
        build_conn()
        |> put_req_header("authorization", "bearer: " <> token(profile))
        |> get(Routes.profile_path(conn, :indications))

      {:ok, _indication_name} = EncryptedField.load(indication.name)

      assert %{
               "indications" => [
                 %{"id" => indication_id, "name" => indication_name}
               ]
             } = json_response(conn, 200)["data"]
    end
  end
end
