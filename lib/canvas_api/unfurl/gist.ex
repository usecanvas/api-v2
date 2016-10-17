defmodule CanvasAPI.Unfurl.Gist do
  @moduledoc """
  An unfurl representing a GitHub gist.
  """

  @gist_regex ~r{https://gist.github.com/[^/]+/[^/]+(?:\.json)?}
  @provider_name "GitHub Gist"
  @provider_url "https://gist.github.com"

  alias CanvasAPI.Unfurl

  @spec gist_regex() :: Regex.t
  def gist_regex, do: @gist_regex

  @spec unfurl(String.t, Keyword.t) :: Unfurl.t | nil
  def unfurl(url, _) do
    if String.ends_with?(url, ".json") do
      do_unfurl(url)
    else
      do_unfurl(url <> ".json")
    end
    |> Map.put(:url, url)
  end

  @spec do_unfurl(String.t) :: Unfurl.t | nil
  defp do_unfurl(url) do
    with {:ok, json} <- get_gist(url) do
      %Unfurl{
        id: url,
        html: append_stylesheet(json["div"], json["stylesheet"]),
        provider_icon_url: CanvasAPI.Unfurl.GitHub.provider_icon_url,
        provider_name: @provider_name,
        provider_url: @provider_url,
        title: get_in(json, ["files", Access.at(0)]),
        text: Map.get(json, "description", "")}
    end
  end

  @spec get_gist(String.t) :: {:ok, map} | {:error, any}
  defp get_gist(url) do
    with {:ok, %{status_code: 200, body: body}} <- HTTPoison.get(url) do
      Poison.decode(body)
    end
  end

  @spec append_stylesheet(String.t, String.t) :: String.t
  defp append_stylesheet(html, stylesheet_url) do
    html <> ~s(<link rel="stylesheet" type="text/css" href="#{stylesheet_url}">)
  end
end
