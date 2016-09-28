defmodule CanvasAPI.WhitelistedSlackDomain do
  @moduledoc """
  A Slack domain whose users may sign in to Canvas.
  """

  use CanvasAPI.Web, :model

  schema "whitelisted_slack_domains" do
    field :domain, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:domain])
    |> validate_required([:domain])
    |> unique_constraint(:domain)
  end
end
