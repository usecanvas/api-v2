defmodule CanvasAPI.Block do
  @moduledoc """
  A block of content in a canvas.
  """

  use CanvasAPI.Web, :model

  @type t :: %__MODULE__{}

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
  @spec changeset(%__MODULE__{}, map) :: Ecto.Changeset.t
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:id, :content, :meta, :type])
    |> cast_embed(:blocks)
  end

  @doc """
  Converts a Block into a plain map with content, meta, type, blocks key.
  """
  @spec to_params(%__MODULE__{}) :: map
  def to_params(struct) do
    struct
    |> Map.take([:content, :meta, :type])
    |> Map.put(:blocks, Enum.map(struct.blocks, &to_params/1))
  end

  @doc """
  Return whether a block matches a given filter string.
  """
  @spec matches_filter?(%__MODULE__{}, String.t) :: boolean
  def matches_filter?(block = %__MODULE__{type: "url"}, filter) do
    do_matches_filter?(block.meta["url"], filter)
  end

  def matches_filter?(block = %__MODULE__{type: "list"}, filter) do
    block.blocks
    |> Enum.any?(&matches_filter?(&1, filter))
  end

  def matches_filter?(block = %__MODULE__{content: content}, filter) when is_binary(content) do
    do_matches_filter?(block.content, filter)
  end

  def matches_filter?(_, _), do: false

  @spec do_matches_filter?(String.t, String.t) :: boolean
  defp do_matches_filter?(string, term) do
    string
    |> String.downcase
    |> String.contains?(String.downcase(term))
  end
end
