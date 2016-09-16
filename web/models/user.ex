defmodule CanvasAPI.User do
  use CanvasAPI.Web, :model

  schema "users" do
    field :email, :string
    field :identity_token, CanvasAPI.EncryptedField
    field :images, :map, default: %{}
    field :name, :string
    field :slack_id, :string

    belongs_to :account, CanvasAPI.Account
    belongs_to :team, CanvasAPI.Team, references: :slack_id, type: :string

    timestamps
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :identity_token, :name, :slack_id])
    |> validate_required([:email, :identity_token, :name, :slack_id])
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
