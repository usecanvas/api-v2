defmodule CanvasAPI.BetaNotifier do
  @moduledoc """
  Notifies Canvas of non-whitelisted domain login attempts.
  """

  use CanvasAPI.Web, :worker
  alias CanvasAPI.Team

  @canvas_domain "usecanvas"
  @notify_user "oren"

  @doc """
  Notify Canvas of a non-whitelisted domain login attempt.
  """
  @spec notify(String.t) :: any
  def notify(domain) do
    get_token
    |> Slack.client
    |> Slack.Chat.postMessage(
         channel: "general",
         text: ":bell: @#{@notify_user} #{domain} just tried to sign in.",
         link_names: true)
  end

  @spec get_token :: String.t | nil | no_return
  defp get_token do
    from(Team, where: [domain: @canvas_domain])
    |> Repo.one!
    |> Team.get_token("slack")
    |> elem(1)
    |> Map.get(:meta)
    |> get_in(["bot", "bot_access_token"])
  end
end
