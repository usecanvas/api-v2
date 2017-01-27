defmodule CanvasAPI.Unfurl.Vimeo do
  @moduledoc """
  An unfurl representing a Vimeo video.
  """

  @vimeo_regex ~r{https://vimeo.com/.+}
  @provider_name "Vimeo"
  @provider_url "https://player.vimeo.com/video/"

  alias CanvasAPI.Unfurl

  @spec vimeo_regex() :: Regex.t
  def vimeo_regex, do: @vimeo_regex

  @doc """
  Unfurl a Vimeo URL.
  """
  @spec unfurl(url :: String.t, opts :: Keyword.t) :: Unfurl.t | nil
  def unfurl(url, _opts \\ []) do
    with {:ok, extracted} <- extract(url) do
      unfurl_from_body(extracted, url)
    else
    _ -> nil
    end
  end

  defp extract(url) do
    HTTPoison.get("https://vimeo.com/api/oembed.json", [], params: [
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
      html: html(extracted["video_id"]),
      title: "Vimeo Clip",
      width: extracted["width"],
      height: extracted["height"],
      provider_name: @provider_name,
      provider_url: @provider_url,
      url: url
    }
  end

  defp html(video_id),
    do: ~s(<iframe src="#{@provider_url}#{video_id}"></iframe>)
end
