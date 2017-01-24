defmodule CanvasAPI.WatchedCanvasService do
  @moduledoc """
  A service for viewing and manipulating watched canvases.
  """

  use CanvasAPI.Web, :service

  alias CanvasAPI.{Canvas, CanvasService, UserService, WatchedCanvas}

  @doc """
  Insert a new watched canvas.
  """
  @spec insert(attrs, Keyword.t) :: {:ok, WatchedCanvas.t}
                                  | {:error, Changeset.t}
  def insert(attrs, opts) do
    %WatchedCanvas{}
    |> WatchedCanvas.changeset(attrs)
    |> put_canvas(attrs["canvas_id"], opts[:account])
    |> put_user(opts[:account])
    |> Repo.insert
  end

  @spec put_canvas(Changeset.t, String.t | nil, Account.t) :: Changeset.t
  defp put_canvas(changeset, id, account) when is_binary(id) do
    id
    |> CanvasService.get(account: account)
    |> case do
      {:ok, canvas} ->
        put_assoc(changeset, :canvas, canvas)
      {:error, _} ->
        add_error(changeset, :canvas, "was not found")
    end
  end

  defp put_canvas(changeset, _, _),
    do: add_error(changeset, :canvas, "is required")

  @spec put_user(Changeset.t, Account.t) :: Changeset.t
  defp put_user(changeset, account) do
    with canvas = %Canvas{} <- get_field(changeset, :canvas) do
      {:ok, user} = UserService.find_by_team(account, team_id: canvas.team_id)
      put_assoc(changeset, :user, user)
    else
        _ -> changeset
    end
  end
end
