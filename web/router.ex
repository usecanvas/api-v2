defmodule CanvasAPI.Router do
  use CanvasAPI.Web, :router

  pipeline :api do
    plug CanvasAPI.TrailingFormatPlug
    plug :accepts, ~w(json json-api)
  end

  scope "/", CanvasAPI do
    scope "/oauth", OAuth do
      get "/slack/callback", Slack.CallbackController, :callback
      get "/github/callback", GitHub.CallbackController, :callback
    end
  end

  scope "/v1", CanvasAPI do
    pipe_through :api

    get "/account", AccountController, :show
    delete "/session", SessionController, :delete

    resources "/teams", TeamController, only: [:index, :show] do
      resources "/canvases", CanvasController, only: [:create, :index, :show, :delete] do
        resources "/unfurls", UnfurlController, only: [:show]
      end

      get "/templates", CanvasController, :index_templates, as: :template
      get "/user", UserController, :show
    end
  end
end
