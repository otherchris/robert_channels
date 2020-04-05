defmodule RobertChannels.MeetingControllerTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use RobertChannelsWeb.ConnCase

  describe "create a meeting" do
    conn =
      build_conn()
      |> post("/api/create_meeting", %{})

    assert conn.status == 200

    %{"meeting_id" => meeting_id} = json_response(conn, 200)
    assert String.length(meeting_id) == 6

    meeting = Process.whereis(String.to_atom(meeting_id))
    %{floor: %{chair: chair}} = :sys.get_state(meeting)
    assert is_binary(chair)
  end
end

