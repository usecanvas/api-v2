defmodule CanvasAPI.BetaNotifier do
  @moduledoc """
  Notifies Canvas of non-whitelisted domain login attempts.
  """

  alias CanvasAPI.{Repo, Team}
  import Ecto.Query, only: [from: 2]

  @canvas_domain "usecanvas"
  @notify_user "jonathan"

  defmodule NotifyWorker do
    @moduledoc """
    Asynchronously notifies Canvas of non-whitelisted domain login attempts.
    """

    def perform(domain) do
      CanvasAPI.BetaNotifier.notify(domain)
    end
  end

  @doc """
  Notify Canvas of a non-whitelisted domain login attempt.
  """
  def notify(domain) do
    get_token
    |> Slack.client
    |> Slack.Chat.postMessage(
         channel: "general",
         text: ":bell: @#{@notify_user} #{domain} just tried to sign in.",
         link_names: true)
  end

  @doc """
  Asynchronously notify Cnavas of a non-whitelisted domain login attempt.
  """
  def delay_notify(domain, opts \\ []) do
    Exq.Enqueuer.enqueue_in(
      CanvasAPI.Queue.Enqueuer,
      "default",
      Keyword.get(opts, :delay, 0),
      NotifyWorker,
      [domain])
  end

  defp get_token do
    from(Team, where: [domain: @canvas_domain])
    |> Repo.one!
    |> Team.get_token("slack")
    |> Map.get(:meta)
    |> get_in(["bot", "bot_access_token"])
  end
end
