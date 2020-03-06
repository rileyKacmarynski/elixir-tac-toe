defmodule ClientAppWeb.LobbyLive do
  use Phoenix.LiveView

  alias ClientAppWeb.Router.Helpers, as: Routes
  alias ClientAppWeb.Presence

  @topic "lobby"

  def mount(_params, session, socket) do

    case Map.fetch(session, "current_user") do
      {:ok, username} -> {:ok,
        socket
        |> assign(current_user: username, users: [])
        |> setup_presence()}
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

  def handle_info(
    %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
    %{assigns: %{lobby_size: count}} = socket
  ) do
    lobby_size = count + map_size(joins) - map_size(leaves)
    users =
      Presence.list(@topic)
      |> Enum.map(fn {username, _data} -> username end)

    {:noreply,
      assign(socket,
        lobby_size: lobby_size,
        users: users
      )}
  end

  defp setup_presence(socket = %{ assigns: %{ current_user: current_user }}) do
    initial_count = Presence.list(@topic) |> map_size

    ClientAppWeb.Endpoint.subscribe(@topic)

    Presence.track(
      self(),
      @topic,
      current_user,
      %{}
    )

    assign(socket, :lobby_size, initial_count)
  end
end
