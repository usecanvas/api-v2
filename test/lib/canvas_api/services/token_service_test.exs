defmodule CanvasAPI.TokenServiceTest do
  use CanvasAPI.ModelCase

  alias CanvasAPI.{PersonalAccessToken, TokenService}
  import CanvasAPI.Factory

  setup do
    account = insert(:account)
    {:ok, account: account}
  end

  describe ".create/2" do
    test "creates a new token from valid params", %{account: account} do
      {:ok, token} =
        TokenService.create(%{}, account: account)
      assert token
      assert token.expires_at > (DateTime.utc_now |> Timex.to_unix)
    end
  end

  describe ".verify/1" do
    setup %{account: account} do
      {:ok, token} = TokenService.create(%{}, account: account)
      {:ok, token: token}
    end

    test "returns the account for a valid token", %{token: token} do
      {:ok, account} =
        token
        |> PersonalAccessToken.formatted_token
        |> TokenService.verify

      assert account.id == token.account_id
    end

    test "returns an error for an invalid token" do
      assert TokenService.verify("hi") == {:error, :invalid_token}
    end

    test "returns an error for an expires token", %{token: token} do
      the_past = DateTime.utc_now |> Timex.shift(hours: -1) |> Timex.to_unix

      token_str =
        token
        |> PersonalAccessToken.changeset
        |> put_change(:expires_at, the_past)
        |> Repo.update!
        |> PersonalAccessToken.formatted_token

      assert TokenService.verify(token_str) == {:error, :invalid_token}
    end
  end
end
