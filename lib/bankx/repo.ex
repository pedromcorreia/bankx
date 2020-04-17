defmodule Bankx.Repo do
  use Ecto.Repo,
    otp_app: :bankx,
    adapter: Ecto.Adapters.Postgres
end
