defmodule BankxWeb.ProfileController do
  use BankxWeb, :controller

  alias Bankx.Account
  alias Bankx.Account.Profile

  action_fallback BankxWeb.FallbackController

  def account(conn, %{"profile" => profile_params}) do
    with %{"cpf" => cpf} <- profile_params,
         %Profile{} = profile <- Account.get_profile_by_cpf(cpf) do
      with {:ok, %Profile{} = profile} <- Account.update_profile(profile, profile_params) do
        render(conn, "show.json", profile: profile)
      end
    else
      _ ->
        with {:ok, %Profile{} = profile} <- Account.create_profile(profile_params) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", Routes.profile_path(conn, :show, profile))
          |> render("show.json", profile: profile)
        end
    end
  end

  def show(conn, %{"id" => id}) do
    profile = Account.get_profile!(id)
    render(conn, "show.json", profile: profile)
  end
end
