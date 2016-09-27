defmodule CanvasAPI.Unfurl do
  defstruct id: nil, fields: [], height: nil, html: nil, labels: [],
    provider_icon_url: nil, provider_name: nil, provider_url: nil, text: nil,
    thumbnail_url: nil, title: nil, type: "link", width: nil

  @type t :: %__MODULE__{
    id: String.t | nil,
    fields: [CanvasAPI.Unfurl.Field.t],
    height: pos_integer | nil,
    html: String.t | nil,
    labels: [CanvasAPI.Unfurl.Label.t],
    provider_icon_url: String.t | nil,
    provider_name: String.t | nil,
    provider_url: String.t | nil,
    text: String.t | nil,
    thumbnail_url: String.t | nil,
    title: String.t | nil,
    type: String.t,
    width: pos_integer | nil
  }

  def json_api_type, do: "unfurl"

  def unfurl(block, account: account) do
    with mod when is_atom(mod) <- get_unfurl_mod(block),
         unfurl when not is_nil(unfurl) <- mod.unfurl(block, account: account) do
      unfurl
    else
      _ ->
        %__MODULE__{id: block.id, title: block.meta["url"] || "No Title"}
    end
  end

  defp get_unfurl_mod(block) do
    url = block.meta["url"] || ""

    cond do
      block.type == "canvas" ->
        CanvasAPI.Unfurl.Canvas
      Regex.match?(~r|\Ahttps?://(?:www\.)?github\.com/|, url) ->
        CanvasAPI.Unfurl.GitHub
      # Regex.match?(~r|\Ahttps?://[^/]*slack\.com/|, url) ->
      #   CanvasAPI.Unfurl.Slack
      Regex.match?(~r|\Ahttps?://|, url) ->
        CanvasAPI.Unfurl.OpenGraph
      true ->
        nil
    end
  end
end
