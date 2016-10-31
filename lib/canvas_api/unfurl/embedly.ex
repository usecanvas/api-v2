defmodule CanvasAPI.Unfurl.Embedly do
  @moduledoc """
  An unfurled page using data from Open Graph HTML tags.
  """

  @embedly_key System.get_env("EMBEDLY_API_KEY")

  @doc """
  Unfurl a GitHub repo URL.
  """
  @spec unfurl(url::String.t, options::Keyword.t) :: Unfurl.t | nil
  def unfurl(url, _opts \\ []) do
    with {:ok, extracted} <- extract(url) do
      unfurl_from_body(extracted, url)
    else
      _ -> nil
    end
  end

  defp extract(url) do
    HTTPoison.get("https://api.embedly.com/1/extract", [], params: [
      key: @embedly_key,
      url: url])
    |> case do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        {:ok, Poison.decode!(body)}
      _ ->
        nil
    end
  end

  defp unfurl_from_body(extracted, url) do
    %CanvasAPI.Unfurl{
      id: url,
      provider_name: extracted["site_name"],
      title: extracted["title"] || url,
      text: extracted["description"],
      thumbnail_url: get_in(extracted, ["images", Access.at(0), "url"]),
      url: url
    }
  end
end
