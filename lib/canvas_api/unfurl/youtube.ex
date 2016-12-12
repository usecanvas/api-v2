defmodule CanvasAPI.Unfurl.Youtube do
  @moduledoc """
  An unfurl representing a Youbute Video
  """

  @youtube_regex ~r{https://www.youtube.com/.+}
  @provider_name "Youtube"
  @provider_url "https://youtube.com"

  alias CanvasAPI.Unfurl

  @spec youtube_regex() :: Regex.t
  def youtube_regex, do: @youtube_regex

  @doc """
  Unfurl a Youtube URL.
  """
  @spec unfurl(url :: String.t, opts :: Keyword.t) :: Unfurl.t | nil
  def unfurl(url, _opts \\ []) do
    IO.puts "Hello World"
    if id = youtube_id(url) do
      unfurl_from_body(id, url)
    end
  end

  defp youtube_id(url) do
    url
    |> URI.parse
    |> Map.get(:query)
    |> URI.decode_query
    |> Map.get("v")
  end

  defp unfurl_from_body(id, url) do
    %CanvasAPI.Unfurl{
      id: url,
      html: ~s(<iframe src="https://www.youtube.com/embed/#{id}"></iframe>),
      title: "Youtube Video",
      provider_name: @provider_name,
      provider_url: @provider_url,
      url: url
    }
  end

end
