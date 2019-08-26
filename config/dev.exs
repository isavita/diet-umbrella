import Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :diet_web, DietWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../apps/diet_web/assets", __DIR__)
    ]
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :diet_web, DietWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/diet_web/{live,views}/.*(ex)$",
      ~r"lib/diet_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Configure your database
config :diet, Diet.Repo,
  username: "postgres",
  password: "postgres",
  database: "diet_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configure http client for wolfram alpha API
config :info_sys, :wolfram_api,
  adapter: InfoSys.WolframApi.WolframInMemory,
  app_id: "XXXXX"

# Configure http client for youtube web API
config :auto_publish, :youtube_web_api,
  adapter: AutoPublish.YoutubeWebApi.YoutubeWebInMemory,
  api_key: System.get_env("YOUTUBE_API_KEY")

# Configure http client for contextual web API
config :diet_web, :contextual_web_api,
  adapter: DietWeb.ContextualWebApi.ContextualWebInMemory,
  api_host: System.get_env("CONTEXTUAL_WEB_API_HOST"),
  api_key: System.get_env("CONTEXTUAL_WEB_API_KEY")

# Configure http client for faroo web API
config :diet_web, :faroo_web_api,
  adapter: DietWeb.FarooWebApi.FarooWebInMemory,
  api_host: System.get_env("FAROO_WEB_API_HOST"),
  api_key: System.get_env("FAROO_WEB_API_KEY")

# Configure http client for eventful web API
config :diet_web, :eventful_web_api,
  adapter: DietWeb.EventfulWebApi.EventfulWebInMemory,
  api_host: System.get_env("EVENTFUL_WEB_API_HOST"),
  api_key: System.get_env("EVENTFUL_WEB_API_KEY"),
  api_cunsumer_key: System.get_env("EVENTFUL_WEB_API_CONSUMER_KEY"),
  api_cunsumer_secret: System.get_env("EVENTFUL_WEB_API_CONSUMER_SECRET")

# Configure http client for edamam web API
config :diet_web, :edamam_web_api,
  adapter: DietWeb.EdamamWebApi.FarooWebHTTPClient,
  api_key: System.get_env("EDAMAM_WEB_API_KEY")

# Configure http client for Food2Fork API
config :diet_web, :food_fork_web_api,
  adapter: DietWeb.FoodForkWebApi.FoodForkWebInMemory,
  api_key: System.get_env("FOOD_FORK_WEB_API_KEY")
