defmodule CanvasAPI.CanvasChannel do
  @moduledoc """
  Communicates canvases-related events along sockets.
  """

  use CanvasAPI.Web, :channel

  alias CanvasAPI.CanvasService

  def join("canvas:" <> canvas_id, _payload, socket) do
    account = socket.assigns[:current_account]

    canvas_id
    |> CanvasService.get(account: account)
    |> case do
      {:ok, _} -> {:ok, socket}
      {:error, _} -> {:error, :canvas_not_found}
    end
  end
end
