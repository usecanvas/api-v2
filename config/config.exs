# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :canvas_api,
  namespace: CanvasAPI,
  ecto_repos: [CanvasAPI.Repo],
  redirect_on_auth_url: System.get_env("REDIRECT_ON_AUTH_URL")

config :canvas_api, CanvasAPI.UploadSignature,
  url: System.get_env("FILE_UPLOAD_URL")

# Configures the endpoint
config :canvas_api, CanvasAPI.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: CanvasAPI.ErrorView, accepts: ~w(json)],
  pubsub: [name: CanvasAPI.PubSub,
           adapter: Phoenix.PubSub.Redis,
           url: System.get_env("REDIS_URL")]

config :phoenix, :format_encoders,
  json: CanvasAPI.JSONEncoder

# Configures Elixir's Logger
config :logger, :console,
  format: "time=$dateT$timeZ level=$level $metadata$message\n",
  metadata: [:request_id],
  utc_log: true

# Configure exq
config :exq,
  url: System.get_env("REDIS_URL"),
  max_retries: 5

# Configure phoenix generators
config :phoenix, :generators,
  binary_id: true

# Configure JSON API mime type
config :plug, :types, %{
  "application/vnd.json+api" => ~w(json-api)
}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
