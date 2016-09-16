defmodule CanvasAPI.Account do
  use CanvasAPI.Web, :model

  schema "accounts" do
    many_to_many :teams, CanvasAPI.Team, join_through: "memberships"
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
