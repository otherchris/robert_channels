defmodule RobertChannels.MeetingControllerTest do
  @moduledoc false

  use ExUnit.Case, async: true
  use RobertChannelsWeb.ConnCase

  test "create a meeting" do
    conn =
      build_conn()
      |> post("/api/create_meeting", %{})

    assert conn.status == 200

    %{"meeting_id" => meeting_id} = json_response(conn, 200)
    assert String.length(meeting_id) == 6

    meeting = Process.whereis(String.to_atom(meeting_id))
    %{chair: chair} = :sys.get_state(meeting)
    assert is_binary(chair)
  end

  describe "POST action" do
    test "recognize a speaker" do
      {:ok, pid} = GenServer.start_link(RulesServer, :ok, name: :MEETIN)

      conn = build_conn()
      |> post("/api/action", %{
        meeting_id: "MEETIN",
        subject: "chair",
        action: "RECOGNIZE",
        payload: %{
          speaker: "new speaker"
        }
      })
      %{speaker: speaker} = :sys.get_state(pid)
      assert speaker == "new speaker"
    end

   test "do not recognize speaker if not chair" do
      {:ok, pid} = GenServer.start_link(RulesServer, :ok, name: :MEETIN)

      conn = build_conn()
      |> post("/api/action", %{
        meeting_id: "MEETIN",
        subject: "not chair",
        action: "RECOGNIZE",
        payload: %{
          speaker: "new speaker"
        }
      })
      %{speaker: speaker} = :sys.get_state(pid)
      assert speaker != "new speaker"
    end

   test "make a motion" do
      {:ok, pid} = GenServer.start_link(RulesServer, :ok, name: :MEETIN)

      conn = build_conn()
      |> post("/api/action", %{
        meeting_id: "MEETIN",
        subject: "not chair",
        action: "MOTION",
        payload: %{
          content: "my motion content"
        }
      })
      %{motion_stack: [last_motion | rest]} = :sys.get_state(pid)
      assert last_motion == %{content: "my motion content", actor_id: "not chair"} 
    end
  end
end

