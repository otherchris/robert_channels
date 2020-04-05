defmodule RobertChannelsWeb.MeetingChannel do
  use RobertChannelsWeb, :channel

  def join("meeting:example", payload, socket) do
    if authorized?(payload) do
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
    actions = RulesServer.check_actions(Process.whereis(:example_server), "chair")
    {:reply, {:ok, %{actions: actions}}, socket}
  end

  def handle_in("act", %{"action_name" => action_name, "object_id" => object_id}, socket) do
    RulesServer.apply_action(
      Process.whereis(:example_server),
      {
        String.to_atom(action_name),
        "chair",
        object_id
      }
    )
    {:reply, {:ok, %{}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
