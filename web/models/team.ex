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
    |> cast(params, [:domain, :name, :slack_id])
    |> validate_required([:domain, :name, :slack_id])
    |> put_images(params)
  end

  # Put images into the changeset.
  @spec put_images(Ecto.Changeset.t, map) :: Ecto.Changeset.t
  defp put_images(changeset, params) do
    changeset
    |> put_change(:images, Enum.reduce(params, %{}, fn ({key, value}, images) ->
      if String.starts_with?(key, "image_") do
        Map.put(images, key, value)
      else
        images
      end
    end))
  end
end
