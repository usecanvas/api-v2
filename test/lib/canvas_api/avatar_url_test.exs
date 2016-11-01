defmodule CanvasAPI.AvatarURLTest do
  use ExUnit.Case, async: true

  test "creates a Gravatar URL" do
    email = "user@example.com"
    url = CanvasAPI.AvatarURL.create(email)
    assert url == "https://www.gravatar.com/avatar/#{hash(email)}"
  end

  defp hash(email) do
    :crypto.hash(:md5, String.downcase(email)) |> Base.encode16(case: :lower)
  end
end
