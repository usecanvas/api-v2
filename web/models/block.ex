defmodule CanvasAPI.Block do
  use CanvasAPI.Web, :model

  @primary_key {:id, CanvasAPI.Base62UUIDField, autogenerate: true}

  embedded_schema do
    field :content, :string, default: ""
    field :meta, :map, default: %{}
    field :type, :string

    embeds_many :blocks, __MODULE__
  end

  @doc """
  Builds a changeset based on `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:content, :meta, :type])
    |> cast_embed(:blocks)
  end
end
