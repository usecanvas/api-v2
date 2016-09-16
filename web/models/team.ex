defmodule CanvasAPI.Team do
  use CanvasAPI.Web, :model

  schema "teams" do
    field :domain, :string
    field :images, :map, default: %{}
    field :name, :string
    field :slack_id, :string

    many_to_many :accounts, CanvasAPI.Account, join_through: "users", join_keys: [team_id: :slack_id, account_id: :id]
    has_many :users, CanvasAPI.User, references: :slack_id

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:domain, :images, :name, :slack_id])
    |> validate_required([:domain, :images, :name, :slack_id])
  end
end
