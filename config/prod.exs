import Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :diet_web, DietWeb.Endpoint,
  load_from_system_env: true,
  url: [scheme: "https", host: "weighthater.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto], hsts: true, host: nil],
  check_origin: true,
  root: ".",
  cache_static_manifest: "priv/static/cache_manifest.json"

# Do not print debug messages in production
config :logger, level: :info

# Configure http client for wolfram alpha API
config :info_sys, :wolfram_api,
  adapter: InfoSys.WolframApi.WolframHTTPClient,
  app_id: System.get_env("WOLFRAM_APP_ID")

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

# Configure http client for eventful web API
config :diet_web, :eventful_web_api,
  adapter: DietWeb.EventfulWebApi.EventfulWebHTTPClient,
  api_host: System.get_env("EVENTFUL_WEB_API_HOST"),
  api_key: System.get_env("EVENTFUL_WEB_API_KEY"),
  api_cunsumer_key: System.get_env("EVENTFUL_WEB_API_CONSUMER_KEY"),
  api_cunsumer_secret: System.get_env("EVENTFUL_WEB_API_CONSUMER_SECRET")

# Configure http client for edamam web API
config :diet_web, :edamam_web_api,
  adapter: DietWeb.EdamamWebApi.EdamamWebHTTPClient,
  api_key: System.get_env("EDAMAM_WEB_API_KEY")

# Configure http client for Food2Fork API
config :diet_web, :food_fork_web_api,
  adapter: DietWeb.FoodForkWebApi.FoodForkWebHTTPClient,
  api_key: System.get_env("FOOD_FORK_WEB_API_KEY")

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :diet_web, DietWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [
#         :inet6,
#         port: 443,
#         cipher_suite: :strong,
#         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
#       ]
#
# The `cipher_suite` is set to `:strong` to support only the
# latest and more secure SSL ciphers. This means old browsers
# and clients may not be supported. You can set it to
# `:compatible` for wider support.
#
# `:keyfile` and `:certfile` expect an absolute path to the key
# and cert in disk or a relative path inside priv, for example
# "priv/ssl/server.key". For all supported SSL configuration
# options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
#
# We also recommend setting `force_ssl` in your endpoint, ensuring
# no data is ever sent via http, always redirecting to https:
#
#     config :diet_web, DietWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases (distillery)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :diet_web, DietWeb.Endpoint, server: true
#
# Note you can't rely on `System.get_env/1` when using releases.
# See the releases documentation accordingly.
