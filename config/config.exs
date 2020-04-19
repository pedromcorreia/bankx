# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bankx,
  ecto_repos: [Bankx.Repo]

# Configures the endpoint
config :bankx, BankxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "Irjhbs2rlMoyzUll0CY13k4qTFVG5dcpVeKTTKm89ulqQSmoG4wx9+kEPKG8ilfP",
  render_errors: [view: BankxWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Bankx.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "DefMQVe1"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
