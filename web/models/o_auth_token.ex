defmodule CanvasAPI.OAuthToken do
  @moduledoc """
  A token for making requests to a third-party API.
  """

  use CanvasAPI.Web, :model

  schema "oauth_tokens" do
    field :token, CanvasAPI.EncryptedField
    field :provider, :string
    field :meta, :map, default: %{}

    belongs_to :account, CanvasAPI.Account

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:token, :provider, :meta])
    |> validate_required([:token, :provider])
    |> unique_constraint(:provider,
         name: :oauth_tokens_account_id_provider_index,
         message: "already exists for this account")
  end
end
