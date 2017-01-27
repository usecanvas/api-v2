defmodule CanvasAPI.Unfurl do
  @moduledoc """
  Some sort of remote data (from GitHub, a web page, Canvas) that is represented
  in a common way for clients to display.
  """

  defstruct id: nil, attachments: [], fields: [], height: nil, html: nil,
    labels: [], provider_icon_url: nil, provider_name: nil, provider_url: nil,
    text: nil, thumbnail_url: nil, title: nil, type: "link", width: nil,
    fetched: true, url: nil

  @type t :: %__MODULE__{
    id: String.t | nil,
    attachments: [map],
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
    width: pos_integer | nil,
    fetched: boolean,
    url: String.t
  }

  def json_api_type, do: "unfurl"

  def unfurl(url, account: account) do
    with mod when is_atom(mod) <- get_unfurl_mod(url),
         unfurl = %__MODULE__{} <- mod.unfurl(url, account: account) do
      unfurl
    else
      _ ->
        %__MODULE__{
          id: url,
          fetched: false,
          title: url,
          url: url}
    end
  end

  defp get_unfurl_mod(url) do
    [{CanvasAPI.Unfurl.Canvas.canvas_regex, CanvasAPI.Unfurl.Canvas},
     {CanvasAPI.Unfurl.Gist.gist_regex, CanvasAPI.Unfurl.Gist},
     {CanvasAPI.Unfurl.Youtube.youtube_regex, CanvasAPI.Unfurl.Youtube},
     {CanvasAPI.Unfurl.Framer.framer_regex, CanvasAPI.Unfurl.Framer},
     {CanvasAPI.Unfurl.Vimeo.vimeo_regex, CanvasAPI.Unfurl.Vimeo},
     {~r|\Ahttps?://(?:www\.)?github\.com/|, CanvasAPI.Unfurl.GitHub},
     {~r|\Ahttps?://[^/]*slack\.com/|, CanvasAPI.Unfurl.Slack},
     {~r|\Ahttps?://|, CanvasAPI.Unfurl.Embedly}]
    |> Enum.find_value(fn {regex, mod} ->
         if Regex.match?(regex, url), do: mod
       end)
  end
end
