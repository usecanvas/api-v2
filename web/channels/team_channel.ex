defmodule CanvasAPI.TeamChannel do
  @moduledoc """
  Communicates team-related news along sockets.
  """

  use CanvasAPI.Web, :channel

  alias CanvasAPI.TeamService

  def join("team:" <> team_id, _payload, socket) do
    account = socket.assigns[:current_account]

    with {:ok, _} <- TeamService.show(team_id, account: account) do
      {:ok, socket}
    else
      _ ->
        {:error, :team_not_found}
    end
  end
end
