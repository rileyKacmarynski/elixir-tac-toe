defmodule ClientAppWeb.LobbyLive do
  use Phoenix.LiveView

  alias ClientAppWeb.Router.Helpers, as: Routes

  def mount(_params, session, socket) do

    case Map.fetch(session, "current_user") do
      {:ok, username} -> {:ok, assign(socket, current_user: username)}
      :error -> {
        :ok,
        redirect(socket, to: Routes.page_path(socket, :login))
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
