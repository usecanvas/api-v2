defmodule CanvasAPI.UIDismissal do
  @moduledoc """
  Represents a user having dismissed a portion of the UI, such as a suggestion.
  """

  use CanvasAPI.Web, :model

  @type t :: %__MODULE__{}

  schema "ui_dismissals" do
    field :identifier, :string

    belongs_to :account, CanvasAPI.Account

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(t, map) :: Ecto.Changeset.t
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:identifier])
    |> validate_required([:identifier])
    |> unique_constraint(:identifier,
                         name: :ui_dismissals_account_id_identifier_index)
  end
end
