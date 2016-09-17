defmodule CanvasAPI.Router do
  use CanvasAPI.Web, :router

  pipeline :api do
    plug :accepts, ~w(json json-api)
  end

  scope "/", CanvasAPI do
    pipe_through :api

    get "/account", AccountController, :show
    delete "/session", SessionController, :delete

    resources "/teams", TeamController, only: [:index, :show] do
      resources "/canvases", CanvasController, only: [:create, :index, :show]
    end

    scope "/oauth", OAuth do
      get "/slack/callback", Slack.CallbackController, :callback
    end
  end
end
