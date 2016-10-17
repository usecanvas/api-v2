defmodule CanvasAPI.Unfurl.Framer do
  @moduledoc """
  An unfurl representing a GitHub gist.
  """

  @framer_regex ~r{https://share.framerjs.com/.+}
  @provider_name "Framer"
  @provider_url "https://framerjs.com"

  alias CanvasAPI.Unfurl

  @spec framer_regex() :: Regex.t
  def framer_regex, do: @framer_regex

  @spec unfurl(String.t, Keyword.t) :: Unfurl.t | nil
  def unfurl(url, _) do
    %Unfurl{
      id: url,
      html: ~s(<iframe src="#{url}"></iframe>),
      provider_name: @provider_name,
      provider_url: @provider_url}
  end
end
