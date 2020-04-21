defmodule BankxWeb.Router do
  use BankxWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug(BankxWeb.Auth)
  end

  scope "/api", BankxWeb do
    pipe_through :api

    post "/profiles/account", ProfileController, :account
  end

  scope "/api", BankxWeb do
    pipe_through [:api, :auth]

    resources "/profiles", ProfileController, only: [:show]
    get "/profiles/indications/:referral_code", ProfileController, :indications
  end
end
