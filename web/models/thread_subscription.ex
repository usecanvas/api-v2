defmodule CanvasAPI.ThreadSubscription do
  @moduledoc """
  A record representing a user having subscribed to receive notifications on
  a specific comment thread.
  """

  use CanvasAPI.Web, :model

  schema "thread_subscriptions" do
    field :subscribed, :boolean

    belongs_to :canvas, CanvasAPI.Canvas, type: :string
    belongs_to :user, CanvasAPI.User
    belongs_to :block, CanvasAPI.Block, type: :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:subscribed])
    |> validate_required([:subscribed])
  end
end
