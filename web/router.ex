defmodule CanvasAPI.Router do
  use CanvasAPI.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CanvasAPI do
    pipe_through :api
  end
end
