use Mix.Config

config :canvas_api,
  redirect_on_auth_url: "http://localhost.test/redirect_on_auth_url"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :canvas_api, CanvasAPI.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :canvas_api, CanvasAPI.UploadSignature,
  url: "https://u:p@canvas-files-prod.s3.amazonaws.com"

# Configure your database
if System.get_env("HEROKU_TEST_RUN_ID") do # Heroku CI
  config :canvas_api, CanvasAPI.Repo,
    adapter: Ecto.Adapters.Postgres,
    url: {:system, "DATABASE_URL"},
    loggers: [Appsignal.Ecto],
    ssl: true
else
  config :canvas_api, CanvasAPI.Repo,
    adapter: Ecto.Adapters.Postgres,
    database: "canvas_pro_api_test",
    hostname: if(System.get_env("DOCKER"), do: "postgres", else: "localhost"),
    username: if(System.get_env("DOCKER"), do: "postgres"),
    pool: Ecto.Adapters.SQL.Sandbox
end
