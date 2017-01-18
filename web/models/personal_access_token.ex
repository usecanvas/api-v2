defmodule CanvasAPI.PersonalAccessToken do
  @moduledoc """
  An access token used to make API calls
  """

  @type t :: %__MODULE__{}

  use CanvasAPI.Web, :model

  schema "personal_access_tokens" do
    field :expires_at, :integer
    field :token, CanvasAPI.EncryptedField

    belongs_to :account, CanvasAPI.Account

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @spec changeset(t, map) :: Ecto.Changeset.t
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> put_change(:token, Base62UUID.generate)
    |> validate_required([:token])
  end

  @doc """
  Formats a token for use in verification.
  """
  @spec formatted_token(t) :: String.t
  def formatted_token(struct) do
    "#{Base62UUID.encode(struct.id)}:#{struct.token}"
  end
end
