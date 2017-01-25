defmodule CanvasAPI.CanvasWatch do
  @moduledoc """
  A canvas that a user has elected to receive direct messages related to it.
  """

  use CanvasAPI.Web, :model

  @type t :: %__MODULE__{}

  schema "canvas_watches" do
    belongs_to :canvas, CanvasAPI.Canvas, type: :string
    belongs_to :user, CanvasAPI.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(t, map) :: Ecto.Changeset.t
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
  end
end
