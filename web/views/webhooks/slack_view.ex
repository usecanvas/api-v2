defmodule CanvasAPI.Webhooks.SlackView do
  use CanvasAPI.Web, :view

  def render("verify.json", %{challenge: challenge}) do
    %{challenge: challenge}
  end
end
