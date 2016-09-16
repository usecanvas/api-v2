defmodule CanvasAPI.Account do
  use CanvasAPI.Web, :model

  schema "accounts" do
    field :email, :string
    field :image_url, :string
    field :slack_id, :string
    many_to_many :teams, CanvasAPI.Team, join_through: "memberships"

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :image_url, :slack_id])
    |> validate_required([:email, :image_url, :slack_id])
  end
end
