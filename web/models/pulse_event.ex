defmodule CanvasAPI.PulseEvent do
  @moduledoc """
  An event related to a canvas.
  """

  use CanvasAPI.Web, :model

  schema "pulse_events" do
    field :provider_name, :string
    field :provider_url, :string
    field :type, :string
    field :url, :string

    belongs_to :canvas, CanvasAPI.Canvas, type: :string
    embeds_one :referencer, CanvasAPI.Referencer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:provider_name, :provider_url, :type, :url])
    |> cast_embed(:referencer)
    |> validate_required([:provider_name, :provider_url, :type, :url])
  end
end
