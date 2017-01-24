defmodule CanvasAPI.Account do
  @moduledoc """
  A user account, representing one or more Slack users.
  """

  use CanvasAPI.Web, :model

  @type t :: %__MODULE__{}

  schema "accounts" do
    many_to_many :teams, CanvasAPI.Team, join_through: "users"
    has_many :users, CanvasAPI.User
    has_many :canvases, through: [:users, :canvases]
    has_many :comments, through: [:canvases, :comments]
    has_many :oauth_tokens, CanvasAPI.OAuthToken
    has_many :personal_access_tokens, CanvasAPI.PersonalAccessToken
    has_many :ui_dismissals, CanvasAPI.UIDismissal
    has_many :watched_canvases, through: [:users, :watched_canvases]

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
  end
end
