import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :sentinel, Sentinel.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "sentinel_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :sentinel, SentinelWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "4pmmELPAAX+Nw3Vz8HedPs98/S+jnchJYT2rfSEM2MKQYaqH7gm0yC+ZqoZjmrPi",
  server: false

# In test we don't send emails
config :sentinel, Sentinel.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :sentinel, Sentinel.Mailer, adapter: Swoosh.Adapters.Test

config :sentinel, Sentinel.Notifications.Email,
  max_retries: 3,
  retry_interval: 50,
  dead_letter_interval: 200

config :sentinel, Sentinel.Notifications.EmailState,
  circuit_breaker_threshold: 5,
  circuit_breaker_timeout: 100
