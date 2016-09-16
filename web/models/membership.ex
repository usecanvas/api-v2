defmodule CanvasAPI.Membership do
  use CanvasAPI.Web, :model

  schema "memberships" do
    field :email, :string
    field :identity_token, CanvasAPI.EncryptedField
    field :image_url, :string
    field :name, :string
    field :slack_id, :string
    belongs_to :team, CanvasAPI.Team
    belongs_to :account, CanvasAPI.Account

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :identity_token, :image_url, :name, :slack_id])
    |> validate_required([:email, :identity_token, :image_url, :name, :slack_id])
  end
end
