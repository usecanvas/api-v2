defmodule CanvasAPI.Team do
  use CanvasAPI.Web, :model

  schema "teams" do
    field :domain, :string
    field :name, :string
    field :slack_id, :string
    many_to_many :members, CanvasAPI.Account, join_through: "memberships"

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:domain, :name, :slack_id])
    |> validate_required([:domain, :name, :slack_id])
  end
end
