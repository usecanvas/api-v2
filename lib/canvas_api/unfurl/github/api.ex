defmodule CanvasAPI.Unfurl.GitHub.API do
  use HTTPoison.Base

  @endpoint "https://api.github.com"
  @token System.get_env("GITHUB_API_TOKEN")

  defp process_url(url) do
    @endpoint <> url
  end

  defp process_request_headers(headers) do
    [{"Authorization", "token #{@token}"} | headers]
  end

  defp process_response_body(body) do
    Poison.decode!(body)
  end
end
