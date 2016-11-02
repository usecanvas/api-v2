defmodule CanvasAPI.CanvasTrackback do
  @moduledoc """
  A "canvas trackback" is an event where a reference to a canvas was either
  added to or removed from another canvas.
  """

  alias CanvasAPI.{Account, AvatarURL, Canvas, PulseEvent, Repo, User}
  import Ecto.Query
  import Ecto.Changeset
  import Ecto

  # target: The canvas that was referenced
  # soruce: The canvas that the target was reference in

  defmodule Worker do
    @moduledoc """
    A worker for creating canvas trackbacks.
    """

    def perform("add", target_canvas_id, source_canvas_id, acct_id) do
      CanvasAPI.CanvasTrackback.add(
        target_canvas_id, source_canvas_id, acct_id)
    end

    def perform("remove", target_canvas_id, source_canvas_id, acct_id) do
      CanvasAPI.CanvasTrackback.remove(
        target_canvas_id, source_canvas_id, acct_id)
    end
  end

  @doc """
  Create an "added" reference event, where the account user added a reference to
  the target canvas to the source canvas.
  """
  @spec add(String.t, String.t, String.t) :: %PulseEvent{} | no_return
  def add(target_id, source_id, acct_id) do
    with {target, source, user} <- get_models(target_id, source_id, acct_id) do
      %PulseEvent{}
      |> PulseEvent.changeset(%{
          provider_name: "Canvas",
          provider_url: "https://pro.usecanvas.com",
          type: "reference_added",
          url: Canvas.web_url(source),
          referencer: %{
            id: user.id,
            avatar_url: AvatarURL.create(user.email),
            email: user.email,
            name: user.name,
            url: "mailto:#{user.email}"
          }
        })
      |> put_assoc(:canvas, target)
      |> Repo.insert!
    end
  end

  @doc """
  Create a "removed" reference event, where the account user removed a reference
  to the target canvas from the source canvas.
  """
  @spec remove(String.t, String.t, String.t) :: %PulseEvent{} | no_return
  def remove(target_id, source_id, acct_id) do
    with {target, source, user} <- get_models(target_id, source_id, acct_id) do
      %PulseEvent{}
      |> PulseEvent.changeset(%{
          provider_name: "Canvas",
          provider_url: "https://pro.usecanvas.com",
          type: "reference_removed",
          url: Canvas.web_url(source),
          referencer: %{
            id: user.id,
            avatar_url: AvatarURL.create(user.email),
            email: user.email,
            name: user.name,
            url: "mailto:#{user.email}"
          }
        })
      |> put_assoc(:canvas, target)
      |> Repo.insert!
    end
  end

  @spec get_models(String.t, String.t, String.t) ::
        {%Canvas{}, %Canvas{}, %User{}}
  defp get_models(target_id, source_id, acct_id) do
    with target = %Canvas{} <- Repo.get(Canvas, target_id),
         source = %Canvas{} <-
           Repo.get(Canvas, source_id) |> Repo.preload([:team]),
         account = %Account{} <- Repo.get(Account, acct_id),
         user = %User{} <- get_user(account, source.team_id) do
      {target, source, user}
    end
  end

  @spec get_user(%Account{}, String.t) :: %User{} | nil
  defp get_user(account, team_id) do
    from(assoc(account, :users), where: [team_id: ^team_id]) |> Repo.one
  end
end
