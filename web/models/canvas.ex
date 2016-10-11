defmodule CanvasAPI.Canvas do
  @moduledoc """
  A document containing content represented as nested JSON blocks that is
  editable in realtime.
  """

  use CanvasAPI.Web, :model

  alias CanvasAPI.Block

  @primary_key {:id, CanvasAPI.Base62UUIDField, autogenerate: true}

  schema "canvases" do
    field :is_template, :boolean, default: false
    field :native_version, :string, default: "1.0.0"
    field :type, :string, default: "http://sharejs.org/types/JSONv0"
    field :version, :integer, default: 0
    field :slack_channel_ids, {:array, :string}, default: []
    field :edited_at, Calecto.DateTimeUTC

    belongs_to :creator, CanvasAPI.User
    belongs_to :team, CanvasAPI.Team
    belongs_to :template, CanvasAPI.Canvas

    embeds_many :blocks, Block, on_replace: :delete

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:is_template, :slack_channel_ids])
    |> cast_embed(:blocks)
    |> put_change(:edited_at, DateTime.utc_now)
    |> put_title_block
  end

  @doc """
  Builds a changeset for updating a canvas.
  """
  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:slack_channel_ids])
  end

  @doc """
  Find a block in the given canvas.
  """
  def find_block(canvas, id) do
    canvas.blocks
    |> Enum.find(fn block ->
      case block do
        %Block{id: ^id} -> block
        %Block{type: "list"} -> find_block(block, id)
        _ -> false
      end
    end)
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
        changeset
        |> cast(%{blocks: Enum.map(blocks, &Block.to_params/1)}, [])
        |> cast_embed(:blocks)
    end
  end

  def put_template(changeset, _), do: changeset

  @doc """
  Get the summary of a canvas.
  """
  @spec summary(%__MODULE__{}) :: String.t
  def summary(%__MODULE__{blocks: blocks}) do
    case Enum.at(blocks, 1) do
      %Block{blocks: [block | _]} ->
        String.slice(block.content, 0..140)
      %Block{content: content} ->
        String.slice(content, 0..140)
      nil ->
        ""
    end
  end

  @doc """
  Get the title of a canvas.
  """
  @spec title(%__MODULE__{}) :: String.t
  def title(%__MODULE__{blocks: blocks}) do
    case blocks do
      [%Block{type: "title", content: content} | _] -> content
      _ -> ""
    end
  end

  @doc """
  Get the web URL of a canvas.
  """
  @spec web_url(%__MODULE__{}) :: String.t
  def web_url(canvas) do
    "#{System.get_env("WEB_URL")}/#{canvas.team.domain}/#{canvas.id}"
  end

  # Put the title block, if necessary.
  @spec put_title_block(Ecto.Changeset.t) :: Ecto.Changeset.t
  defp put_title_block(changeset) do
    changeset
    |> get_change(:blocks)
    |> case do
      [%Ecto.Changeset{changes: %{type: "title"}} | _] ->
        changeset
      blocks_changeset when is_list(blocks_changeset) ->
        put_embed(changeset, :blocks, [title_changeset | blocks_changeset])
      nil ->
        put_embed(changeset, :blocks, [title_changeset])
    end
  end

  # Get a title block.
  @spec title_changeset :: Ecto.Changeset.t
  defp title_changeset do
    Block.changeset(%Block{}, %{type: "title"})
  end
end
