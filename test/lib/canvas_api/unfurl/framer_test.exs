defmodule CanvasAPI.Unfurl.FramerTest do
  use ExUnit.Case, async: true

  alias CanvasAPI.Unfurl
  alias CanvasAPI.Unfurl.Framer, as: UnfurlFramer

  test "unfurls with an iFrame" do
    url = "https://share.framerjs.com/blah-blah-blah"
    unfurl = UnfurlFramer.unfurl(url)
    assert unfurl == %Unfurl{
      id: url,
      html: ~s(<iframe src="#{url}"></iframe>),
      provider_name: "Framer",
      provider_url: "https://framerjs.com",
      url: url}
  end
end
