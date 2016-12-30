defmodule CanvasAPI.Op do
  @moduledoc """
  An op in a canvas's history.
  """

  use CanvasAPI.Web, :model

  @type t :: %__MODULE__{}
  @primary_key false

  schema "ops" do
    field :components, {:array, :map}
    field :meta, :map
    field :seq, :integer
    field :source, :string
    field :version, :integer

    belongs_to :canvas, CanvasAPI.Canvas, type: :string

    timestamps()
  end
end
