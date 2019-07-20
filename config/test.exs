use Mix.Config

# Configure your database
config :diet, Diet.Repo,
  username: "postgres",
  password: "postgres",
  database: "diet_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :diet_web, DietWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
