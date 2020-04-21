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

  defp get_meeting(meeting_id) do
    meeting_id
    |> String.to_atom()
    |> Process.whereis
  end
end
