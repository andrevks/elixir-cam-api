import Config

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: ElixirCamApi.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Logger configuration for production
config :logger,
  backends: [:console], # Default backend, can add more (e.g., file backend)
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ],
  level: :info

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
