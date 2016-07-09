use Mix.Config

import_config "../apps/*/config/config.exs"

# This still has issues so this should be left false until I have more time to investigate.
enable_elk_logging = false

config :logger,
  enable_elk_logging: enable_elk_logging

unless enable_elk_logging == true do
  config :logger,
    backends: [:console]
else
  config :logger,
    backends: [{LoggerLogstashBackend, :debug_log}, :console]

  config :logger, :debug_log,
    host: "127.0.0.1",
    port: 10001,
    level: :debug,
    type: "test",
    metadata: [
  ]
end
