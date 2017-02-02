defmodule CanvasAPI.ThreadSubscriptionView do
  @moduledoc """
  A view for rendering thread subscriptions.
  """

  use CanvasAPI.Web, :view
  alias CanvasAPI.{Endpoint, UserView}

  def render("index.json", %{thread_subscriptions: thread_subscriptions}) do
    %{
      data: render_many(thread_subscriptions,
                        __MODULE__,
                        "thread_subscription.json"),
      included: Enum.map(thread_subscriptions,
                         &include_thread_subscription_user/1)
    }
  end

  def render("show.json", %{thread_subscription: thread_subscription}) do
    %{
      data: render_one(thread_subscription,
                       __MODULE__,
                       "thread_subscription.json"),
      included: include_thread_subscription_user(thread_subscription)
    }
  end

  def render("thread_subscription.json",
             %{thread_subscription: thread_subscription}) do
    %{
      id: thread_subscription.block_id,
      attributes: %{
        subscribed: thread_subscription.subscribed,
        inserted_at: thread_subscription.inserted_at,
        updated_at: thread_subscription.updated_at
      },
      relationships: %{
        block: %{data: %{id: thread_subscription.block_id, type: "block"}},
        canvas: %{
          data: %{id: thread_subscription.canvas_id, type: "canvas"},
          links: %{
            related: team_canvas_path(
                       Endpoint,
                       :show,
                       thread_subscription.canvas.team_id,
                       thread_subscription.canvas.id)
          }
        },
        user: %{data: %{id: thread_subscription.user_id, type: "user"}}
      },
      type: "thread-subscription"
    }
  end

  defp include_thread_subscription_user(thread_subscription = %{user: user}) do
    user
    |> Map.put(:team, thread_subscription.canvas.team)
    |> render_one(UserView, "user.json")
  end
end
