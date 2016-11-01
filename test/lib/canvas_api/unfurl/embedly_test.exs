defmodule CanvasAPI.Unfurl.EmbedlyTest do
  use ExUnit.Case

  @embedly_key nil
  @embedly_url "https://api.embedly.com/1/extract"

  alias CanvasAPI.Unfurl
  alias CanvasAPI.Unfurl.Embedly, as: UnfurlEmbedly
  import Mock

  test "unfurls via Embedly" do
    url = "https://en.wikipedia.org/wiki/Operational_transformation"

    with_mock HTTPoison, [get: mock_get(url)] do
      unfurl = UnfurlEmbedly.unfurl(url)
      assert unfurl == %Unfurl{
        id: url,
        provider_name: "Wikipedia",
        title: "Operational transformation - Wikipedia",
        text: "Description",
        thumbnail_url: "image-url",
        url: url}
    end
  end

  defp mock_get(url) do
    fn(@embedly_url, _headers, params: [key: @embedly_key, url: ^url]) ->
      {:ok,
       %HTTPoison.Response{
         status_code: 200,
         body: Poison.encode!(%{
           "site_name" => "Wikipedia",
           "title" => "Operational transformation - Wikipedia",
           "description" => "Description",
           "images" => [%{"url" => "image-url"}]})}}
    end
  end
end
