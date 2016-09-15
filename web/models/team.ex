defmodule CanvasAPI.Team do
  use CanvasAPI.Web, :model

  schema "teams" do
    field :domain, :string
    field :name, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:domain, :name])
    |> validate_required([:domain, :name])
  end
end
