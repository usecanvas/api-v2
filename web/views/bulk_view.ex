defmodule CanvasAPI.BulkView do
  use CanvasAPI.Web, :view
  import CanvasAPI.JSONAPIView

  def render("bulk.json", %{descriptors: descriptors}) do
    descriptors
    |> json_object
  end
end
