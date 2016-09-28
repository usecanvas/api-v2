defmodule CanvasAPI.Unfurl.GitHub.API do
  use HTTPoison.Base

  alias CanvasAPI.Repo
  import Ecto.Query, only: [from: 2]

  @endpoint "https://api.github.com"

  def get_by(account, url) do
    headers =
      case get_token_for_block(account) do
        nil -> []
        token ->
          [{"authorization", "token #{token.token}"}]
      end

    get(url, headers)
  end

  def get_token_for_block(account) do
    from(t in Ecto.assoc(account, :oauth_tokens),
         where: t.provider == ^"github")
    |> Repo.one
  end


  defp process_url(url = "https://" <> _), do: url
  defp process_url(url), do: @endpoint <> url

  defp process_request_body(body), do: Poison.encode!(body)

  defp process_response_body(body), do: Poison.decode!(body)
end
