defmodule CanvasAPI.UploadSignatureView do
  use CanvasAPI.Web, :view

  def render("show.json", %{signature: signature}) do
    signature
    |> resource_object(Map.take(signature, Map.keys(signature)))
    |> json_object
  end
end
