defmodule RobertChannelsWeb.MeetingChannel do
  use RobertChannelsWeb, :channel

  def join("meeting:" <> meeting_id, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :meeting_id, meeting_id)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (meeting:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  def handle_in("actions", _, socket) do
    actions =
      socket
      |> get_meeting
      |> RulesServer.check_actions(socket.assigns.subject_id)
    {:reply, {:ok, %{actions: actions}}, socket}
  end

  def handle_in("act", %{"action_name" => action_name, "object_id" => object_id}, socket = %{assigns: %{subject_id: subject_id}}) do
    socket
    |> get_meeting
    |> RulesServer.apply_action({String.to_atom(action_name), subject_id, object_id})
    {:reply, {:ok, %{}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp get_meeting(socket = %{assigns: %{meeting_id: meeting_id}}) do
    meeting_id
    |> String.to_atom()
    |> Process.whereis
  end
end
