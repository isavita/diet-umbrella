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
  api_host: "XXXXX",
  api_key: "XXXXX"

# Configure http client for faroo web API
config :diet_web, :faroo_web_api,
  adapter: DietWeb.FarooWebApi.FarooWebInMemory,
  api_host: "XXXXX",
  api_key: "XXXXX"

# Configure http client for eventful web API
config :diet_web, :eventful_web_api,
  adapter: DietWeb.EventfulWebApi.EventfulWebInMemory,
  api_host: "XXXXX",
  api_key: "XXXXX",
  api_cunsumer_key: "XXXXX",
  api_cunsumer_secret: "XXXXX"

# Configure http client for edamam web API
config :diet_web, :edamam_web_api,
  adapter: DietWeb.EdamamWebApi.FarooWebInMemory,
  api_key: "XXXXX"

# Configure http client for Food2Fork API
config :diet_web, :food_fork_web_api,
  adapter: DietWeb.FoodForkWebApi.FarooWebHTTPClient,
  api_key: "XXXXX"
