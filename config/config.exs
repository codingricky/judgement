# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :judgement,
  ecto_repos: [Judgement.Repo]

# Configures the endpoint
config :judgement, Judgement.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vHxxSp9JTrLAKFANUreafoUfUBA3YWnCyfxs8qIvcuJMPaIdLgs55FUgiKU7wLwl",
  render_errors: [view: Judgement.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Judgement.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :judgement, Google,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
  redirect_uri: "http://localhost:4000/auth/google/callback"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"