import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :diet_web, DietWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :diet, Diet.Repo,
  username: "postgres",
  password: "postgres",
  database: "diet_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Config for hashing of passwords to less secure but faster version for tests
config :pbkdf2_elixir, :rounds, 1

# Configure fake http client for wolfram alpha API
config :info_sys, :wolfram_api,
  adapter: InfoSys.WolframApi.WolframInMemory,
  app_id: "XXXXX"

# Configure http client for contextual web API
config :diet_web, :contextual_web_api,
  adapter: DietWeb.ContextualWebApi.ContextualWebInMemory,
  api_host: System.get_env("CONTEXTUAL_WEB_API_HOST"),
  api_key: System.get_env("CONTEXTUAL_WEB_API_KEY")
