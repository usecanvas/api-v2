defmodule CanvasAPI.CanvasTrackback do
  @moduledoc """
  A reference from one canvas to another.
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

  def add(target_id, source_id, acct_id) do
    with [target, source, user] <- get_models(target_id, source_id, acct_id) do
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

  def remove(target_id, source_id, acct_id) do
    with [target, source, user] <- get_models(target_id, source_id, acct_id) do
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

  defp get_models(target_id, source_id, acct_id) do
    with target = %Canvas{} <- Repo.get(Canvas, target_id),
         source = %Canvas{} <-
           Repo.get(Canvas, source_id) |> Repo.preload([:team]),
         account = %Account{} <- Repo.get(Account, acct_id),
         user = %User{} <- get_user(account, source.team_id) do
      [target, source, user]
    end
  end

  defp get_user(account, team_id) do
    from(assoc(account, :users), where: [team_id: ^team_id]) |> Repo.one
  end
end
