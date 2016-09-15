defmodule CanvasAPI.Router do
  use CanvasAPI.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CanvasAPI do
    pipe_through :api

    scope "/oauth", OAuth do
      get "/slack/callback", Slack.CallbackController, :callback
    end
  end
end
