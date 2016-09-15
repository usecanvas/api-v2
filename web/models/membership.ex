defmodule CanvasAPI.Membership do
  use CanvasAPI.Web, :model

  schema "memberships" do
    field :identity_token, CanvasAPI.EncryptedField
    belongs_to :team, CanvasAPI.Team
    belongs_to :account, CanvasAPI.Account

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:identity_token])
    |> validate_required([:identity_token])
  end
end
