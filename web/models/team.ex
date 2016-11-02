defmodule CanvasAPI.Team do
  @moduledoc """
  A group of users in a Slack team.
  """

  use CanvasAPI.Web, :model

  alias CanvasAPI.ImageMap

  schema "teams" do
    field :domain, :string
    field :images, :map, default: %{}
    field :name, :string
    field :slack_id, :string

    many_to_many :accounts, CanvasAPI.Account, join_through: "users"
    has_many :canvases, CanvasAPI.Canvas
    has_many :users, CanvasAPI.User
    has_many :oauth_tokens, CanvasAPI.OAuthToken

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:domain, :name, :slack_id])
    |> if_slack(&validate_required(&1, [:domain, :name]))
    |> if_slack(&prevent_domain_change(&1))
    |> unique_constraint(:domain)
    |> put_change(:images, ImageMap.image_map(params))
  end

  @doc """
  Builds a changeset for changing a team domain.
  """
  def change_domain(struct, params \\ %{}) do
    struct
    |> cast(params, [:domain])
    |> if_slack(&prevent_domain_change(&1))
    |> validate_required([:domain])
    |> prefix_domain
    |> unique_constraint(:domain)
  end

  @doc """
  Fetches the OAuth token for the given team and provider.
  """
  def get_token(team, provider) do
    from(assoc(team, :oauth_tokens), where: [provider: ^provider])
    |> first
    |> Repo.one
  end

  defp if_slack(changeset, func) do
    if changeset.data.slack_id || get_change(changeset, :slack_id) do
      func.(changeset)
    else
      changeset
    end
  end

  defp prevent_domain_change(changeset) do
    if changeset.data.slack_id do
      changeset
      |> add_error(:domain, "can not be changed for Slack teams")
    else
      changeset
    end
  end

  defp prefix_domain(changeset) do
    domain = "~#{get_change(changeset, :domain)}"
    put_change(changeset, :domain, domain)
  end
end
