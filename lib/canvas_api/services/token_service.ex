defmodule CanvasAPI.TokenService do
  @moduledoc """
  A service for viewing and manipulating access tokens.
  """

  alias CanvasAPI.{Account, PersonalAccessToken}
  use CanvasAPI.Web, :service

  @preload [:account]

  @doc """
  Create a new personal access token for a given account.
  """
  @spec create(map, Keyword.t) :: {:ok, PersonalAccessToken.t}
                                | {:error, Ecto.Changeset.t}
  def create(attrs, opts) do
    %PersonalAccessToken{}
    |> PersonalAccessToken.changeset(attrs)
    |> put_expires_at(opts[:expires])
    |> put_assoc(:account, opts[:account])
    |> Repo.insert
  end

  @spec put_expires_at(Ecto.Changeset.t, boolean | nil) :: Ecto.Changeset.t
  defp put_expires_at(changeset, nil) do
    changeset
    |> put_change(:expires_at, expires_at())
  end

  defp put_expires_at(changeset, false), do: changeset

  @doc """
  Get a token by ID.
  """
  @spec get(String.t) :: {:ok, PersonalAccessToken.t}
                       | {:error, :token_not_found}
  def get(id, _opts \\ []) do
    PersonalAccessToken
    |> preload(^@preload)
    |> Repo.get(id)
    |> case do
      token = %PersonalAccessToken{} ->
        {:ok, token}
      nil ->
        {:error, :token_not_found}
    end
  end

  @doc """
  Verify a token.
  """
  @spec verify(String.t) :: {:ok, Account.t} | {:error, :invalid_token}
  def verify(token) do
    with [id, token_str] <- String.split(token, ":", parts: 2),
         {:ok, id} <- Base62UUID.decode(id),
         {:ok, access_token} <- get(id),
         true <- validate_expires_at(access_token),
         true <- access_token.token == token_str do
      {:ok, access_token.account}
    else
      _ ->
        {:error, :invalid_token}
    end
  end

  @spec expires_at() :: pos_integer
  defp expires_at() do
    DateTime.utc_now
    |> Timex.shift(minutes: 5)
    |> Timex.to_unix
  end

  @spec validate_expires_at(PersonalAccessToken.t) :: boolean
  defp validate_expires_at(token) do
    if token.expires_at do
      token.expires_at >= DateTime.utc_now |> Timex.to_unix
    else
      true
    end
  end
end
