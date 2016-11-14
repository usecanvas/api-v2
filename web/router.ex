defmodule CanvasAPI.Router do
  use CanvasAPI.Web, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  pipeline :oauth do
    plug :fetch_session
    plug Plug.CSRFProtection, with: :clear_session
  end

  pipeline :api do
    plug CanvasAPI.OriginCheckPlug
    plug :fetch_session
    plug Plug.CSRFProtection, with: :clear_session
    plug CanvasAPI.TrailingFormatPlug
    plug :accepts, ~w(json json-api)
  end

  scope "/", CanvasAPI do
    get "/boom", MetaController, :boom
    get "/health", MetaController, :health

    scope "/webhooks", Webhooks do
      post "/slack", SlackController, :handle
      # post "/github", GitHubController, :handle # Handled by a plug
    end

    scope "/oauth", OAuth do
      pipe_through :oauth

      get "/slack/callback", Slack.CallbackController, :sign_in,
        as: :sign_in_with_slack_callback
      get "/slack/add-to-slack/callback", Slack.CallbackController, :add_to,
        as: :add_to_slack_callback
      get "/github/callback", GitHub.CallbackController, :callback,
        as: :github_callback
    end
  end

  scope "/v1", CanvasAPI do
    pipe_through :api

    get "/account", AccountController, :show
    get "/upload-signature", UploadSignatureController, :show
    post "/bulk", BulkController, :bulk
    delete "/session", SessionController, :delete
    resources "/unfurls", UnfurlController, only: [:index]

    resources "/teams", TeamController, only: [:index, :show, :update] do
      scope "/slack", Slack do
        resources "/channels", ChannelController, only: [:index]
      end

      resources "/canvases", CanvasController do
        resources "/pulse-events", PulseEventController, only: [:index]
      end

      get "/templates", CanvasController, :index_templates, as: :template
      get "/user", UserController, :show
    end
  end
end
