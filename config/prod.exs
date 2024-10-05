import Config

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Sentinel.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

config :sentinel, Sentinel.Notifications.Email,
  max_retries: 3,
  retry_interval: 5_000,
  dead_letter_interval: 120_000

config :sentinel, Sentinel.Notifications.EmailState,
  circuit_breaker_threshold: 5,
  circuit_breaker_timeout: 60_000
