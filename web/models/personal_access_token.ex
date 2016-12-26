defmodule CanvasAPI.PersonalAccessToken do
  @moduledoc """
  An access token used to make API calls
  """

  use CanvasAPI.Web, :model

  schema "personal_access_tokens" do
    field :token, CanvasAPI.EncryptedField
    belongs_to :account, CanvasAPI.Account

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> put_change(:token, Base62UUID.generate)
    |> validate_required([:token])
  end
end
