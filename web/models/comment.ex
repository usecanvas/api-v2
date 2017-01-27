defmodule CanvasAPI.Comment do
  @moduledoc """
  A comment on a block in a canvas by a user.
  """

  use CanvasAPI.Web, :model

  @type t :: %__MODULE__{}

  schema "comments" do
    field :block_id, :string

    belongs_to :creator, CanvasAPI.User
    belongs_to :canvas, CanvasAPI.Canvas, type: :string

    embeds_many :blocks, CanvasAPI.Block, on_replace: :delete

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> cast_embed(:blocks)
  end
end
