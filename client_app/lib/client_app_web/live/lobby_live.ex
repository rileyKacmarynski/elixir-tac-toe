defmodule ClientAppWeb.LobbyLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, msg: 0)}
  end

  def render(assigns) do
    ~L"""
      <h1>Hi!</h1>
      <%= @msg %>
      <button phx-click="inc">+</button>
    """
    # Phoenix.View.render(ClientAppWeb.PageView, "index.html", assigns)
  end

  def handle_event("inc", _value, socket) do
    {:noreply, assign(socket, msg: socket.assigns.msg + 1)}
  end

end
