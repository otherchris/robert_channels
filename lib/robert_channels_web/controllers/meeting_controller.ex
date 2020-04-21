defmodule RobertChannelsWeb.MeetingController do
  @moduledoc """
  Controller for creating meetings
  """

  use RobertChannelsWeb, :controller

  def create(conn, _params) do
    name =
      gen_reference()
      |> String.to_atom

    {:ok, server} = GenServer.start_link(RulesServer, :ok, name: name)

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, %{meeting_id: name} |> Jason.encode!())
  end

  def act(conn, _params) do
    meeting = Process.whereis(conn.body_params["meeting_id"] |> String.to_atom)
    subject = conn.body_params["subject"]
    action = conn.body_params["action"]
    payload = conn.body_params["payload"]

    case action do
      "RECOGNIZE" -> 
        RulesServer.recognize(meeting, payload["speaker"], subject)
      "MOTION" -> 
        RulesServer.motion(meeting, payload["content"], subject)
    end

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, conn.body_params |> Jason.encode!())
  end

  defp gen_reference() do
    min = String.to_integer("100000", 36)
    max = String.to_integer("ZZZZZZ", 36)

    max
    |> Kernel.-(min)
    |> :rand.uniform()
    |> Kernel.+(min)
    |> Integer.to_string(36)
  end
end
