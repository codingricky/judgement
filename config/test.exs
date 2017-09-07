use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :judgement, Judgement.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :info

# Configure your database
config :judgement, Judgement.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "judgement_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :slack, respond_to_slack: false
config :judgement, :chat_client, MockSlackClient
