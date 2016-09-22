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
    belongs_to :template, CanvasAPI.Canvas

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

  @doc """
  Put a template in a canvas if present.
  """
  @spec put_template(Ecto.Changeset.t, map | nil) :: Ecto.Changeset.t
  def put_template(changeset, %{"id" => id, "type" => "canvases"}) do
    case Repo.get(__MODULE__, id) do
      nil ->
        changeset
      %__MODULE__{blocks: blocks} ->
        put_change(changeset, :blocks, copy_template_blocks(blocks))
    end
  end

  def put_template(changeset, _), do: changeset

  # Copy blocks from a template
  @spec copy_template_blocks([map] | []) :: [map] | []
  defp copy_template_blocks([]), do: []

  defp copy_template_blocks([head | tail]) do
    case head["blocks"] do
      nil ->
        [Map.put(head, "id", Base62UUID.generate) | copy_template_blocks(tail)]
      blocks when is_list(blocks) ->
        [head
         |> Map.put("id", Base62UUID.generate)
         |> Map.put("blocks", copy_template_blocks(blocks))
         | copy_template_blocks(tail)]
    end
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
  defp put_title_block(changeset, struct) do
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
