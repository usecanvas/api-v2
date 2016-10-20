defmodule CanvasAPI.Trackback do
  @moduledoc """
  A reference from some place (canvas, GitHub commit, Slack channel message) to
  a canvas.
  """

  @callback add(map, String.t) :: {:ok, %CanvasAPI.PulseEvent{}}
                                | {:ok, [%CanvasAPI.PulseEvent{}]}
                                | {:error, Ecto.Changeset.t}
                                | nil

  defmacro __using__(_opts) do
    quote do
      alias CanvasAPI.{AvatarURL, Canvas, OAuthToken, PulseEvent,
                       PulseEventService, Repo, Team, User}
      import Ecto.Changeset, only: [put_assoc: 3]
      import Ecto.Query, only: [from: 2]
      import Ecto, only: [assoc: 2]

      @behaviour CanvasAPI.Trackback

      @canvas_regex Regex.compile!(
        "#{System.get_env("WEB_URL")}/[^/]+/(?<id>[^/]{22})")

      def perform(params, team_id), do: add(params, team_id)

      def delay_add(params, team_id) do
        Exq.Enqueuer.enqueue(
          CanvasAPI.Queue.Enqueuer,
          "default",
          __MODULE__,
          [params, team_id])
      end

      defp get_canvas(text) do
        with match when match != nil
               <- Regex.named_captures(@canvas_regex, text) do
          Repo.get(Canvas, match["id"])
        end
      end

      defp get_user(team, user_id) do
        from(assoc(team, :users), where: [slack_id: ^user_id]) |> Repo.one
      end
    end
  end
end
