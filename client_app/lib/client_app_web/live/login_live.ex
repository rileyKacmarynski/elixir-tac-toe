defmodule ClientAppWeb.LoginLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, username: "")}
  end

  def render(assigns) do
    Phoenix.View.render(ClientAppWeb.PageView, "login.html", assigns)
  end

  def handle_event("login", _value, socket) do
    {:noreply, assign(socket, username: socket.assigns.username)}
  end

end
