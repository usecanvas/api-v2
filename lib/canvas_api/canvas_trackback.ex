defmodule CanvasAPI.CanvasTrackback do
  alias CanvasAPI.{Account, Canvas, Repo, User}
  import Ecto.Query
  import Ecto

  defmodule Worker do
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
      IO.inspect user
    end
  end

  def remove(target_id, source_id, acct_id) do
    with [target, source, user] <- get_models(target_id, source_id, acct_id) do
      IO.inspect user
    end
  end

  defp get_models(target_id, source_id, acct_id) do
    with target = %Canvas{} <- Repo.get(Canvas, target_id),
         source = %Canvas{} <- Repo.get(Canvas, source_id),
         account = %Account{} <- Repo.get(Account, acct_id),
         user = %User{} <- get_user(account, source.team_id) do
      [target, source, user]
    end
  end

  defp get_user(account, team_id) do
    from(assoc(account, :users), where: [team_id: ^team_id]) |> Repo.one
  end
end
