defmodule CanvasAPI.Canvas do
  use CanvasAPI.Web, :model

  @primary_key {:id, :string, autogenerate: false}

  schema "canvases" do
    field :blocks, {:array, :map}
    field :is_template, :boolean, default: false
    field :native_version, :string, default: "1.0.0"
    field :type, :string, default: "http://sharejs.org/types/JSONv0"
    field :version, :integer, default: 0

    belongs_to :creator, CanvasAPI.User
    belongs_to :team, CanvasAPI.Team

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:blocks, :is_template])
    |> put_title_block(struct)
    |> put_id(struct)
  end

  # Put an ID, if necessary.
  @spec put_id(Ecto.Changeset.t, %__MODULE__{}) :: Ecto.Changeset.t
  defp put_id(changeset, struct) do
    case struct.id do
      nil -> put_change(changeset, :id, Base62UUID.generate)
      _id -> changeset
    end
  end

  # Put the title block, if necessary.
  @spec put_title_block(Ecto.Changeset.t, %__MODULE__{}) :: Ecto.Changeset.t
  defp put_title_block(changeset, struct \\ %__MODULE__{}) do
    case get_change(changeset, :blocks) || struct.blocks do
      [%{"type" => "title"} | _] ->
        changeset
      blocks when is_list(blocks) ->
        put_change(changeset, :blocks, [title_block | blocks])
      _ ->
        put_change(changeset, :blocks, [title_block])
    end
  end

  # Get a title block.
  @spec title_block :: map
  defp title_block do
    %{id: Base62UUID.generate, type: "title", content: "", meta: %{}}
  end
end
