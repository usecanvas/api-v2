defmodule CanvasAPI.UnfurlView do
  use CanvasAPI.Web, :view

  def render("show.json", %{unfurl: unfurl}) do
    unfurl
    |> resource_object(Map.take(unfurl, Map.keys(unfurl)))
    |> json_object
  end
end
