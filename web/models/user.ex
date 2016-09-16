defmodule CanvasAPI.User do
  use CanvasAPI.Web, :model

  schema "users" do
    field :email, :string
    field :identity_token, CanvasAPI.EncryptedField
    field :images, :map, default: %{}
    field :name, :string
    field :slack_id, :string

    belongs_to :account, CanvasAPI.Account
    belongs_to :team, CanvasAPI.Team, references: :slack_id

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :identity_token, :images, :name, :slack_id])
    |> validate_required([:email, :identity_token, :images, :name, :slack_id])
  end
end
