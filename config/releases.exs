import Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).

config :diet_web, DietWeb.Endpoint,
  http: [:inet6, port: System.get_env("PORT")],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configures live view
config :diet_web, DietWeb.Endpoint,
  live_view: [
    signing_salt: System.get_env("LIVE_VIEW_SIGNING_SALT")
  ]

# Configure your database
config :diet, Diet.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

# Configure http client for wolfram alpha API
config :info_sys, :wolfram_api,
  adapter: InfoSys.WolframApi.WolframHTTPClient,
  app_id: System.fetch_env!("WOLFRAM_APP_ID")

# Configure http client for contextual web API
config :diet_web, :contextual_web_api,
  adapter: DietWeb.ContextualWebApi.ContextualWebHTTPClient,
  api_host: System.get_env("CONTEXTUAL_WEB_API_HOST"),
  api_key: System.get_env("CONTEXTUAL_WEB_API_KEY")

# Configure http client for faroo web API
config :diet_web, :faroo_web_api,
  adapter: DietWeb.FarooWebApi.FarooWebHTTPClient,
  api_host: System.get_env("FAROO_WEB_API_HOST"),
  api_key: System.get_env("FAROO_WEB_API_KEY")

config :diet_web, DietWeb.Endpoint, server: true
