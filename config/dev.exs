use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :canvas_api, CanvasAPI.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :canvas_api, CanvasAPI.UploadSignature,
  url: System.get_env("FILE_UPLOAD_URL") ||
         "https://u:p@canvas-files-prod.s3.amazonaws.com"

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :canvas_api, CanvasAPI.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "canvas_pro_api_dev",
  hostname: "localhost",
  pool_size: 10

if System.get_env("DOCKER") do
  config :canvas_api, CanvasAPI.Repo,
    hostname: "postgres",
    username: "postgres"
end

config :mix_test_watch,
  tasks: ["test --stale", "credo --strict"]
