defmodule CanvasAPI.UploadSignatureController do
  use CanvasAPI.Web, :controller

  alias CanvasAPI.UploadSignature

  @doc """
  Return an upload signature for uploading assets to Amazon S3.
  """
  @spec show(Plug.Conn.t, Plug.Params.t) :: Plug.Conn.t
  def show(conn, _params) do
    conn
    |> render("show.json", signature: UploadSignature.generate)
  end
end
