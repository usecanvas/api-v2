defmodule CanvasAPI.Referencer do
  @moduledoc """
  A user of some service that has referenced a canvas.
  """

  use CanvasAPI.Web, :model

  @primary_key {:id, :string, autogenerate: false}

  embedded_schema do
    field :avatar_url, :string
    field :email, :string
    field :name, :string
    field :url, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:avatar_url, :id, :email, :name, :url])
    |> validate_required([:id])
  end
end
