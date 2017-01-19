defmodule CanvasAPI.CanvasChannelTest do
  use CanvasAPI.ChannelCase

  alias CanvasAPI.CanvasChannel
  import CanvasAPI.Factory

  setup do
    canvas = insert(:canvas)
    account = canvas.creator.account

    {:ok, _, socket} =
      socket("current_account", %{current_account: account})
      |> subscribe_and_join(CanvasChannel, "canvas:#{canvas.id}")

    {:ok, socket: socket}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
