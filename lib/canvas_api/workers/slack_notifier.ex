defmodule CanvasAPI.SlackNotifier do
  @moduledoc """
  Notifes a Slack channel of canvas activity.
  """

  use CanvasAPI.Web, :worker

  alias CanvasAPI.{Block, Canvas, CanvasWatch, CanvasWatchService, Comment,
                   CommentService, User}

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
  Direct message a Slack user of a new comment.
  """
  @spec dm_new_comment(String.t, String.t) :: any
  def dm_new_comment(token, comment_id) do
    with {:ok, comment} <- CommentService.get(comment_id),
         watches <- CanvasWatchService.list(canvas: comment.canvas) do
      watches
      |> Enum.each(fn watch -> dm_watch(token, comment, watch) end)
    end
  end

  @spec dm_watch(String.t, Comment.t, CanvasWatch.t) :: any
  defp dm_watch(_, %{creator_id: user_id}, %{user_id: user_id}), do: :ok

  defp dm_watch(token, comment, watch) do
    with {:ok, im_id} <- get_im_id(token, watch.user),
         block = Canvas.find_block(comment.canvas, comment.block_id) do
      token
      |> Slack.client
      |> Slack.Chat.postMessage(new_comment_message(im_id, comment, block))
    end
  end

  @spec get_im_id(String.t, User.t) :: {:ok, String.t} | :error
  defp get_im_id(token, user) do
    token
    |> Slack.client
    |> Slack.IM.open(user: user.slack_id)
    |> case do
      {:ok, %{"channel" => %{"id" => id}}} -> {:ok, id}
      _ -> :error
    end
  end

  @doc """
  Notify a Slack channel of a new comment.
  """
  @spec notify_new_comment(String.t, String.t, String.t) :: any
  def notify_new_comment(token, comment_id, channel_id) do
    with comment = %Comment{} <- Repo.get(Comment, comment_id),
         comment = Repo.preload(comment, [:creator, canvas: [:creator, :team]]),
         block = Canvas.find_block(comment.canvas, comment.block_id) do
      Slack.client(token)
      |> Slack.Chat.postMessage(new_comment_message(channel_id, comment, block))
    end
  end

  @spec new_comment_message(String.t, Comment.t, Block.t) :: Keyword.t
  defp new_comment_message(channel_id, comment, block) do
    [channel: channel_id,
     parse: "full",
     text: notify_new_comment_text(comment.creator),
     attachments: Poison.encode!([%{
       title: Canvas.title(comment.canvas),
       title_link: Canvas.web_url(comment.canvas) <> "?block=#{block.id}",
       text: Canvas.summary(%{blocks: [block]})
     }, %{
       author_name: comment.creator.name,
       author_icon: user_icon_url(comment.creator),
       text: Canvas.summary(comment)
     }])]
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
