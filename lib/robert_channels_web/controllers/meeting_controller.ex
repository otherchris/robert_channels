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

  def gen_reference() do
    min = String.to_integer("100000", 36)
    max = String.to_integer("ZZZZZZ", 36)

    max
    |> Kernel.-(min)
    |> :rand.uniform()
    |> Kernel.+(min)
    |> Integer.to_string(36)
  end
end
