defmodule ClientAppWeb.LobbyLive do
  use Phoenix.LiveView

  alias ClientAppWeb.Router.Helpers, as: Routes

  def mount(_params, _session, socket) do

    # socket = assign(socket, username: "bob")

    case Map.fetch(socket.assigns, :username) do
      {:ok, _username} -> {:ok, socket}
      :error -> {
        :ok,
        push_redirect(socket, to: Routes.live_path(socket, ClientAppWeb.LoginLive))
      }

    end
  end

  def render(assigns) do
    Phoenix.View.render(ClientAppWeb.PageView, "index.html", assigns)
  end

  def handle_event("inc", _value, socket) do
    {:noreply, assign(socket, msg: socket.assigns.msg + 1)}
  end

end
