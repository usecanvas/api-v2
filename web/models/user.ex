defmodule CanvasAPI.User do
  @moduledoc """
  A Slack user.
  """

  use CanvasAPI.Web, :model

  alias CanvasAPI.ImageMap

  @type t :: %__MODULE__{}

  schema "users" do
    field :email, :string
    field :identity_token, CanvasAPI.EncryptedField
    field :images, :map, default: %{}
    field :name, :string
    field :slack_id, :string

    belongs_to :account, CanvasAPI.Account
    belongs_to :team, CanvasAPI.Team
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
    |> validate_required([:email, :name])
    |> put_change(:images, ImageMap.image_map(params))
    |> unique_constraint(:team_id,
         name: :users_account_id_team_id_index,
         message: "already exists for this account")
  end
end
