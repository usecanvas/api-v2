defmodule CanvasAPI.SlackChannelNotifier do
  @moduledoc """
  Notifes a Slack channel of canvas activity.
  """

  alias CanvasAPI.{Canvas, User}

  @doc """
  Notify a Slack channel of a new canvas.
  """
  @spec notify_new(String.t, %Canvas{}, %User{}, String.t) :: any
  def notify_new(token, canvas, notifier, channel_id) do
    Slack.client(token)
    |> Slack.Chat.postMessage(
      channel: channel_id,
      text: notify_new_text(notifier),
      attachments: Poison.encode!([%{
        author_name: canvas.creator.name,
        author_icon: user_icon_url(canvas.creator),
        title: Canvas.title(canvas),
        title_link: Canvas.web_url(canvas),
        text: Canvas.summary(canvas)
      }])
    )
  end

  # Get the text for a new canvas notice.
  @spec notify_new_text(%User{}) :: String.t
  defp notify_new_text(user),
    do: "#{user.name} posted a new canvas to this channel:"

  # Get a Gravatar URL for a user.
  @spec user_icon_url(%User{}) :: String.t
  defp user_icon_url(user) do
    email_hash =
      :crypto.hash(:md5, String.downcase(user.email))
      |> Base.encode16(case: :lower)

    "https://www.gravatar.com/avatar/#{email_hash}"
  end
end
