defmodule RobertChannelsWeb.MeetingChannel do
  use RobertChannelsWeb, :channel

  def join("meeting:" <> meeting_id, payload, socket) do
    with {:ok, _, _} <-
      {:ok, payload, meeting_id}
      |> authorized?()
      |> meeting_exists?()
    do
      socket = 
        socket
        |> assign(:meeting_id, meeting_id)
        |> assign(:subject_id, "chair")
      {:ok, socket}
    else
      {:error, msg} -> {:error, %{reason: msg}}
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
      |> Enum.reject(fn({k, v}) -> !v end)
      |> Enum.map(fn({k, v}) -> k end)
    {:reply, {:ok, %{actions: actions}}, socket}
  end

  def handle_in("act", %{"action_name" => action_name, "object_id" => object_id}, socket = %{assigns: %{subject_id: subject_id}}) do
    socket
    |> get_meeting
    |> RulesServer.apply_action({String.to_atom(action_name), subject_id, object_id})

    broadcast(socket, "update", %{"meeting_id" => socket.assigns.meeting_id})

    {:reply, {:ok, %{}}, socket}
  end

  # Checks on joining.
  defp authorized?({:ok, payload, meeting_id}) do
    {:ok, payload, meeting_id}
  end
  defp authorized?({:error, msg}), do: {:error, msg}

  defp meeting_exists?({:ok, payload, meeting_id}) do
    if is_nil(Process.whereis(String.to_atom(meeting_id))) do
      {:error, "no_meeting"}
    else
      {:ok, payload, meeting_id}
    end
  end
  defp meeting_exists?({:error, msg}), do: {:error, msg}

  defp get_meeting(socket = %{assigns: %{meeting_id: meeting_id}}) do
    meeting_id
    |> String.to_atom()
    |> Process.whereis
  end
end
