defmodule CanvasAPI.Account do
  use CanvasAPI.Web, :model

  schema "accounts" do
    field :email, :string
    field :slack_id, :string

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :slack_id])
    |> validate_required([:email, :slack_id])
  end
end
