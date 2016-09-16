defmodule CanvasAPI.Team do
  use CanvasAPI.Web, :model

  schema "teams" do
    field :domain, :string
    field :name, :string
    field :image_url, :string
    field :slack_id, :string
    many_to_many :members, CanvasAPI.Account, join_through: "memberships"

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:domain, :image_url, :name, :slack_id])
    |> validate_required([:domain, :image_url, :name, :slack_id])
  end
end
