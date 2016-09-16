defmodule CanvasAPI.User do
  use CanvasAPI.Web, :model

  alias CanvasAPI.ImageMap

  schema "users" do
    field :email, :string
    field :identity_token, CanvasAPI.EncryptedField
    field :images, :map, default: %{}
    field :name, :string
    field :slack_id, :string

    belongs_to :account, CanvasAPI.Account
    belongs_to :team, CanvasAPI.Team, references: :slack_id, type: :string
    has_many :canvases, through: [:team, :canvases]
    has_many :created_canvases, CanvasAPI.Canvas

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :identity_token, :name, :slack_id])
    |> validate_required([:email, :identity_token, :name, :slack_id])
    |> put_change(:images, ImageMap.image_map(params))
  end
end
