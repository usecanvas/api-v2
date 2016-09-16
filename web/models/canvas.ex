defmodule CanvasAPI.Canvas do
  use CanvasAPI.Web, :model

  alias CanvasAPI.Base62UUID

  @primary_key {:id, :string, autogenerate: false}

  schema "canvases" do
    field :blocks, {:array, :map}
    field :native_version, :string, default: "1.0.0"
    field :type, :string, default: "http://sharejs.org/types/JSONv0"
    field :version, :integer, default: 0

    belongs_to :creator, CanvasAPI.Account
    belongs_to :team, CanvasAPI.Team

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> put_change(:blocks, [title_block])
    |> put_change(:id, Base62UUID.generate)
  end

  # Get a title block.
  @spec title_block :: map
  defp title_block do
    %{id: Base62UUID.generate, type: "title", content: "", meta: %{}}
  end
end
