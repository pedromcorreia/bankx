defmodule BankxWeb.Auth do
  @moduledoc """
  This plug use for auth
  """

  import Plug.Conn
  alias Bankx.Account
  alias Bankx.Account.Profile

  def init(_), do: nil

  def call(
        %Plug.Conn{params: %{"cpf" => cpf, "referral_code" => referral_code}} =
          conn,
        _opts
      ) do
    with %Profile{} = profile <- Account.get_profile(referral_code) do
      if profile.cpf == cpf do
        assign(conn, :profile, profile)
      else
        conn
        |> send_resp(401, "unauthorized")
        |> halt
      end
    end
  end

  def call(conn, _opts) do
    conn
    |> send_resp(404, "not_found")
    |> halt
  end
end
