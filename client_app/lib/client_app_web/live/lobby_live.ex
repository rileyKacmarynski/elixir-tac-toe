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

  def handle_event("invite",
    %{"user" => user},
    %{assigns: %{current_user: current_user}} = socket
  ) do
    IO.puts("#{current_user} -> #{user}")

    broadcast_message!("game_invite", %{to: user, from: current_user})
    {:noreply, socket}
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

  # not sure if this is the right way to do it.
  # we want to only send invite to one person, but we have to
  # have a websocket connect with them to send the message in the first place
  def handle_info(
    %{event: "game_invite", payload: %{to: to, from: from} = payload},
    %{assigns: %{current_user: current_user}} = socket
  ) do
    case to do
      ^current_user ->
        # pop up something so they can accept and do below with event
        game_id = :rand.uniform(999999)
        # IO.puts("#{current_user} -> #{from}")
        broadcast_message!("accept_invite", %{ to: from, from: to, game_id: game_id})

        {:noreply,
          redirect(socket, to: Routes.live_path(socket, ClientAppWeb.PlayLive, game_id))}
      _ -> {:noreply, socket}
    end
  end

  def handle_info(
    %{event: "accept_invite", payload: %{to: to, game_id: game_id}},
    %{assigns: %{current_user: current_user}} = socket
  ) do
    case to do
      ^current_user ->
        {:noreply,
          redirect(socket, to: Routes.live_path(socket, ClientAppWeb.PlayLive, game_id))}
      _ -> {:noreply, socket}
    end
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

  defp broadcast_message!(event, payload) do
    ClientAppWeb.Endpoint.broadcast_from!(
      self(),
      @topic,
      event,
      payload
    )
  end
end
