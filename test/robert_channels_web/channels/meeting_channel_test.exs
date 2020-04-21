defmodule RobertChannelsWeb.MeetingChannelTest do
  use RobertChannelsWeb.ChannelCase
  use RobertChannelsWeb.ConnCase

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

  test "update message is pushed on recognize", %{socket: socket = %{assigns: %{meeting_id: meeting_id}}} do
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
