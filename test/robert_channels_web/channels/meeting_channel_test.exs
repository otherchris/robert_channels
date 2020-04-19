defmodule RobertChannelsWeb.MeetingChannelTest do
  use RobertChannelsWeb.ChannelCase

  setup do
    {:ok, pid} = GenServer.start_link(RulesServer, :ok, name: :MEETIN)
    {:ok, _, socket} =
      socket(RobertChannelsWeb.UserSocket, "user_id", %{subject_id: "chair"})
      |> subscribe_and_join(RobertChannelsWeb.MeetingChannel, "meeting:MEETIN")

    %{socket: socket, server_name: :MEETIN}
  end

  test "join error if meeting does not exist" do
    {:error, msg} = 
      socket(RobertChannelsWeb.UserSocket, "user_id", %{subject_id: "chair"})
      |> subscribe_and_join(RobertChannelsWeb.MeetingChannel, "meeting:NOPE")
    assert msg == %{reason: "no_meeting"}
  end

  test "actions replies with list of actions", %{socket: socket} do
    ref = push(socket, "actions", %{})
    assert_reply(ref, :ok, %{actions: [_ | _]})
  end

  test "apply action", %{socket: socket} do
    ref = push(socket, "act", %{"action_name" => "recognize", "object_id" => "theguy"})
    assert_reply(ref, :ok, %{})
    %{floor: %{speaker: speaker}} = (:sys.get_state(Process.whereis(socket.assigns.meeting_id |> String.to_atom)))
    assert speaker == "theguy"
  end

  test "update message is pushed on action", %{socket: socket = %{assigns: %{meeting_id: meeting_id}}} do
    ref = push(socket, "act", %{"action_name" => "recognize", "object_id" => "theguy"})
    assert_broadcast "update", %{"meeting_id" => meeting_id}
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
