defmodule CanvasAPI.Unfurl.GistTest do
  use ExUnit.Case

  alias CanvasAPI.Unfurl
  alias CanvasAPI.Unfurl.Gist, as: UnfurlGist
  import Mock

  test "unfurls via a GitHub Gist" do
    url = "https://gist.github.com/user/id.json"

    with_mock HTTPoison, [get: mock_get(url)] do
      unfurl = UnfurlGist.unfurl(url)
      assert unfurl == %Unfurl{
        id: url,
        html: ~s(<div id="gist"></div><link rel="stylesheet" type="text/css" href="styles.css">),
        provider_icon_url: CanvasAPI.Unfurl.GitHub.provider_icon_url,
        provider_name: "GitHub Gist",
        provider_url: "https://gist.github.com",
        title: "file_01.ex",
        text: "Description",
        url: url}
    end
  end

  defp mock_get(url) do
    fn(^url) ->
      {:ok,
       %HTTPoison.Response{
         status_code: 200,
         body: Poison.encode!(%{
           "div" => ~s(<div id="gist"></div>),
           "stylesheet" => "styles.css",
           "files" => ["file_01.ex"],
           "description" => "Description"})}}
    end
  end
end
