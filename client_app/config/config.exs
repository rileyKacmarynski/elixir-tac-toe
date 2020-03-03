# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :client_app, ClientAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SE3Jw6qVAMuZP8UqEGeWcK1SNN9Ku31qHb8sc1cHFX7W9jWuocYLr37LD+Rhbmwy",
  render_errors: [view: ClientAppWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ClientApp.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
