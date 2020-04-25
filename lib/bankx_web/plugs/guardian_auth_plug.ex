defmodule BankxWeb.GuardianAuth do
  @moduledoc """
  This plug use for auth
  """

  import Plug.Conn
  alias Bankx.Account
  alias Bankx.Account.Profile

  def init(_), do: nil

  def call(
        %Plug.Conn{params: %{"token" => token}} = conn,
        _opts
      ) do
    with {:ok, %{"sub" => referral_code}} =
           Bankx.Guardian.decode_and_verify(token),
         %Profile{} = profile <- Account.get_profile(referral_code) do
      assign(conn, :profile, profile)
    else
      _ ->
        conn
        |> send_resp(401, "unauthorized")
        |> halt
    end
  end

  def call(conn, _opts) do
    conn
    |> send_resp(404, "not_found")
    |> halt
  end
end
