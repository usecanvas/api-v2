defmodule CanvasAPI.SlackChannelNotifier do
  @moduledoc """
  Notifes a Slack channel of canvas activity.
  """

  alias CanvasAPI.{Canvas, Comment, Repo, User}

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

  defmodule NotifyNewCommentWorker do
    @moduledoc """
    Asynchronously notifies Slack channels of new comments.
    """

    def perform(token, comment_id, channel_id) do
      CanvasAPI.SlackChannelNotifier.notify_new_comment(
        token,
        comment_id,
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

  @doc """
  Notify a Slack channel of a new comment.
  """
  @spec notify_new_comment(String.t, String.t, String.t) :: any
  def notify_new_comment(token, comment_id, channel_id) do
    with comment = %Comment{} <- Repo.get(Comment, comment_id),
         comment = Repo.preload(comment, [:creator, canvas: [:creator, :team]]),
         notifier = comment.creator,
         block = Canvas.find_block(comment.canvas, comment.block_id) do
      Slack.client(token)
      |> Slack.Chat.postMessage(
        channel: channel_id,
        parse: "full",
        text: notify_new_comment_text(notifier),
        attachments: Poison.encode!([%{
          title: Canvas.title(comment.canvas),
          title_link: Canvas.web_url(comment.canvas) <> "?block=#{block.id}",
          text: Canvas.summary(%{blocks: [block]})
        }, %{
          author_name: notifier.name,
          author_icon: user_icon_url(notifier),
          text: Canvas.summary(comment)
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

  def delay_notify_new_comment(token, comment_id, channel_id, opts \\ []) do
    Exq.Enqueuer.enqueue_in(
      CanvasAPI.Queue.Enqueuer,
      "default",
      Keyword.get(opts, :delay, 0),
      NotifyNewCommentWorker,
      [token, comment_id, channel_id])
  end

  # Get the text for a new canvas notice.
  @spec notify_new_text(%User{}) :: String.t
  defp notify_new_text(user),
    do: "#{user.name} posted a new canvas to this channel:"

  # Get the text for a new comment notice.
  @spec notify_new_comment_text(User.t) :: String.t
  defp notify_new_comment_text(user),
    do: "#{user.name} commented on a canvas in this channel:"

  # Get a Gravatar URL for a user.
  @spec user_icon_url(%User{}) :: String.t
  defp user_icon_url(user) do
    CanvasAPI.AvatarURL.create(user.email)
  end
end
