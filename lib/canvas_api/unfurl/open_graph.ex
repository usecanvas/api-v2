defmodule CanvasAPI.Unfurl.OpenGraph do
  @moduledoc """
  An unfurled page using data from Open Graph HTML tags.
  """

  def unfurl(url, _) do
    case HTTPoison.get(url, [], follow_redirect: true, max_redirect: 5) do
      {:ok, %{body: body, status_code: 200}} ->
        unfurl_from_body(body, url)
      _ ->
        nil
    end
  end

  defp unfurl_from_body(body, url) do
    og_tags = get_opengraph(body)

    %CanvasAPI.Unfurl{
      id: url,
      provider_name: og_tags["site_name"],
      title: og_tags["title"] || url,
      text: og_tags["description"],
      thumbnail_url: og_tags["image"] ||
        og_tags["image:secure_url"] ||
        og_tags["image:url"],
      url: url
    }
  end

  defp get_opengraph(html_body) do
    html_body
    |> Floki.find("meta")
    |> extract_opengraph
    |> Enum.reduce(%{}, fn key_value, map ->
      ensure_valid_string(key_value, map)
    end)
  end

  defp ensure_valid_string({key, value}, map) do
    if String.valid?(value) do
      Map.put(map, key, value)
    else
      Map.put(map, key, "")
    end
  end

  defp extract_opengraph(tags) do
    tags
    |> Enum.reduce(%{}, fn
      (tag = {"meta", attributes, _}, data) ->
        with key when not is_nil(key) <- find_opengraph_key(attributes),
             [value | _] <- Floki.attribute(tag, "content") do
          Map.put(data, key, value)
        else
          _ -> data
        end
    end)
  end

  defp find_opengraph_key(attributes) do
    attributes
    |> Enum.find_value(fn attribute ->
      case attribute do
        {"property", "og:" <> key} -> key
        _ -> nil
      end
    end)
  end
end
