defmodule ClientAppWeb.LobbyLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do

    socket = assign(socket, username: "bob")

    {:ok, socket}
  end

  def render(assigns) do
    Phoenix.View.render(ClientAppWeb.PageView, "index.html", assigns)
  end

  def handle_event("inc", _value, socket) do
    {:noreply, assign(socket, msg: socket.assigns.msg + 1)}
  end

end
