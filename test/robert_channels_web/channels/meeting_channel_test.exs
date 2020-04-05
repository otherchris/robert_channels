defmodule RobertChannelsWeb.MeetingChannelTest do
  use RobertChannelsWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      socket(RobertChannelsWeb.UserSocket, "user_id", %{some: :assign})
      |> subscribe_and_join(RobertChannelsWeb.MeetingChannel, "meeting:example")

    {:ok, socket: socket}
  end

  test "actions replies with list of actions", %{socket: socket} do
    ref = push(socket, "actions", %{})
    assert_reply(ref, :ok, %{actions: [_ | _]})
  end

  test "apply action", %{socket: socket} do
    ref = push(socket, "act", %{"action_name" => "recognize", "object_id" => "theguy"})
    assert_reply(ref, :ok, %{})
    %{floor: %{speaker: speaker}} = (:sys.get_state(Process.whereis(:example_server)))
    assert speaker == "theguy"
  end

  test "shout broadcasts to meeting:lobby", %{socket: socket} do
    push socket, "shout", %{"hello" => "all"}
    assert_broadcast "shout", %{"hello" => "all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
