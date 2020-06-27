# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :phoenix_cms, PhoenixCmsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YaB/9AGtqn0FZoEYe8dTQ9T6agXXD/i9ALB2QJ/xa/IAl6RwJCz9UkYHAxuFtMmK",
  render_errors: [view: PhoenixCmsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: PhoenixCms.PubSub,
  live_view: [signing_salt: "QmCJSvb4"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
