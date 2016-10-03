defmodule CanvasAPI.Router do
  use CanvasAPI.Web, :router

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
    pipe_through :oauth

    scope "/oauth", OAuth do
      get "/slack/callback", Slack.CallbackController, :callback
      get "/github/callback", GitHub.CallbackController, :callback
    end
  end

  scope "/v1", CanvasAPI do
    pipe_through :api

    get "/account", AccountController, :show
    delete "/session", SessionController, :delete
    resources "/unfurls", UnfurlController, only: [:index]

    resources "/teams", TeamController, only: [:index, :show] do
      resources "/canvases", CanvasController,
        only: [:create, :index, :show, :delete]

      get "/templates", CanvasController, :index_templates, as: :template
      get "/user", UserController, :show
    end
  end
end
