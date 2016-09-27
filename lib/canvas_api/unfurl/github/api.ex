defmodule CanvasAPI.Unfurl.GitHub.API do
  use HTTPoison.Base

  @endpoint "https://api.github.com"

  defp process_url(url = "https://" <> _), do: url
  defp process_url(url), do: @endpoint <> url

  defp process_request_body(body), do: Poison.encode!(body)

  defp process_response_body(body), do: Poison.decode!(body)
end
