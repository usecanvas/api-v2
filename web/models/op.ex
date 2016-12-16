defmodule CanvasAPI.Op do
  @moduledoc """
  An op in a canvas's history.
  """

  use CanvasAPI.Web, :model

  @primary_key false
  schema "ops" do
    field :components, {:array, :map}
    field :version, :integer

    belongs_to :canvas, CanvasAPI.Canvas, type: :string

    timestamps()
  end
end
