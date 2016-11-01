defmodule CanvasAPI.UploadSignatureView do
  use CanvasAPI.Web, :view

  def render("show.json", %{signature: signature}) do
    signature
    |> resource_object(%{
         policy: signature.policy,
         signature: signature.signature,
         upload_url: signature.upload_url
       })
    |> json_object
  end
end
