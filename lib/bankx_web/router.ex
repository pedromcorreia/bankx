defmodule BankxWeb.Router do
  use BankxWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BankxWeb do
    pipe_through :api
    resources "/profiles", ProfileController, except: [:new, :edit]
  end
end
