defmodule CanvasAPI.Unfurl.GitHub.API do
  use HTTPoison.Base

  alias CanvasAPI.{Account, OAuthToken, Repo, User}
  import Ecto.Query, only: [from: 2]

  @endpoint "https://api.github.com"

  def get_by(creator_id, url) do
    headers =
      case get_token_for_block(creator_id) do
        nil -> []
        token ->
          [{"authorization", "token #{token.token}"}]
      end

    get(url, headers)
  end

  def get_token_for_block(creator_id) do
    from(t in OAuthToken,
         join: a in Account, on: a.id == t.account_id,
         join: u in User, on: u.account_id == a.id,
         where: u.id == ^creator_id,
         where: t.provider == ^"github")
     |> Repo.one
  end


  defp process_url(url = "https://" <> _), do: url
  defp process_url(url), do: @endpoint <> url

  defp process_request_body(body), do: Poison.encode!(body)

  defp process_response_body(body), do: Poison.decode!(body)
end
