defmodule BankxWeb.Router do
  use BankxWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug(BankxWeb.Auth)
  end

  pipeline :guardian do
    plug(BankxWeb.GuardianAuth)
  end

  scope "/api", BankxWeb do
    pipe_through :api

    post "/profiles/account", ProfileController, :account
  end

  scope "/api", BankxWeb do
    pipe_through [:api, :auth]

    resources "/profiles", ProfileController, only: [:show]
    get "/profiles/sign_in/:referral_code", ProfileController, :sign_in
  end

  scope "/api", BankxWeb do
    pipe_through [:api, :guardian]

    resources "/profiles", ProfileController, only: [:show]
    get "/profiles/indications/:token", ProfileController, :indications
  end
end
