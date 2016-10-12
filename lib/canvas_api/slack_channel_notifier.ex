defmodule CanvasAPI.SlackChannelNotifier do
  @moduledoc """
  Notifes a Slack channel of canvas activity.
  """

  alias CanvasAPI.{Canvas, Repo, User}

  defmodule NotifyNewWorker do
    @moduledoc """
    Asynchronously notifies Slack channels of new canvases.
    """

    def perform(token, canvas_id, notifier_id, channel_id) do
      CanvasAPI.SlackChannelNotifier.notify_new(
        token,
        canvas_id,
        notifier_id,
        channel_id)
    end
  end

  @doc """
  Notify a Slack channel of a new canvas.
  """
  @spec notify_new(String.t, String.t, String.t, String.t) :: any
  def notify_new(token, canvas_id, notifier_id, channel_id) do
    with canvas = %Canvas{} <- Repo.get(Canvas, canvas_id),
         canvas = Repo.preload(canvas, [:creator, :team]),
         notifier = %User{} <- Repo.get(User, notifier_id) do
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
        }]))
    end
  end

  def delay_notify_new(token, canvas_id, notifier_id, channel_id, opts \\ []) do
    Exq.Enqueuer.enqueue_in(
      CanvasAPI.Queue.Enqueuer,
      "default",
      Keyword.get(opts, :delay, 0),
      NotifyNewWorker,
      [token, canvas_id, notifier_id, channel_id])
  end

  # Get the text for a new canvas notice.
  @spec notify_new_text(%User{}) :: String.t
  defp notify_new_text(user),
    do: "#{user.name} posted a new canvas to this channel:"

  # Get a Gravatar URL for a user.
  @spec user_icon_url(%User{}) :: String.t
  defp user_icon_url(user) do
    CanvasAPI.AvatarURL.create(user.email)
  end
end
