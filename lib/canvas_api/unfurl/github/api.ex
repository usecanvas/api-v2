defmodule CanvasAPI.Unfurl.GitHub.API do
  @moduledoc """
  An API used for requesting information from GitHub.
  """

  use HTTPoison.Base

  alias CanvasAPI.{OAuthToken, Repo}
  import Ecto.Query, only: [from: 2]
  import Ecto, only: [assoc: 2]

  @endpoint "https://api.github.com"

  @doc """
  Get a URL by way of a given account.

  Fetches the proper authentication token for the given account, and if it finds
  one, appends it as a header to the GET request.
  """
  @spec get_by(%CanvasAPI.Account{}, String.t) ::
    {:ok, HTTPoison.Response.t} | {:error, HTTPoison.Error.t}
  def get_by(account, url) do
    get(url, headers(account))
  end

  # Get the headers for a request, with a token for the account if available.
  @spec headers(%CanvasAPI.Account{}) :: [] | [{String.t, String.t}]
  defp headers(account) do
    from(t in assoc(account, :oauth_tokens),
         where: t.provider == "github",
         order_by: [desc: :inserted_at],
         limit: 1)
    |> Repo.one
    |> case do
      token = %OAuthToken{} -> [{"authorization", "token #{token.token}"}]
      nil -> []
    end
  end

  defp process_url(url = "https://" <> _), do: url
  defp process_url(url), do: @endpoint <> url
  defp process_request_body(""), do: ""
  defp process_request_body(body), do: Poison.encode!(body)
  defp process_response_body(body), do: Poison.decode!(body)
end
