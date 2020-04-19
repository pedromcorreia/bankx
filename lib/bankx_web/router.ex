defmodule BankxWeb.Router do
  use BankxWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BankxWeb do
    pipe_through :api

    resources "/profiles", ProfileController, only: [:show]
    post "/profiles/account", ProfileController, :account
    get "/profiles/indications/:referral_code", ProfileController, :indications
  end
end
