defmodule ClientAppWeb.LobbyLive do
  use Phoenix.LiveView

  alias ClientAppWeb.Router.Helpers, as: Routes
  alias ClientAppWeb.Presence
  alias ClientAppWeb.ModalLive

  @topic "lobby"

  def mount(_params, session, socket) do

    case Map.fetch(session, "current_user") do
      {:ok, username} -> {:ok,
      socket
      |> assign(
        current_user: username,
        users: [],
        show_modal: false,
        invite_from: "")
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

  def handle_params(params, uri, socket),
    do: handle_params(params, uri, last_path_segment(uri), socket)

  def handle_params(_params, _uri, nil, socket) do
    {:noreply, assign(socket, show_modal: false)}
  end

  def handle_params(%{"from" => from} , _uri, "accept-invite",
    %{assigns: %{show_modal: _}} = socket
  ) do
    {:noreply, assign(socket, show_modal: true, invite_from: from)}
  end

  def handle_params(_params, _uri, _last_path_segment, socket) do
    {:noreply,
      push_patch(socket,
        to: Routes.live_path(socket, ClientAppWeb.LobbyLive),
        replace: true
      )}
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

      {:noreply, assign(
        socket,
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
        # display invite modal
        {:noreply,
        push_patch(
          socket,
          to: Routes.accept_invite_live_path(socket, ClientAppWeb.LobbyLive, from),
          replace: false
        )}
      _ -> {:noreply, socket}
    end
  end

  def handle_info(
      {ModalLive,
      :button_clicked,
      %{action: "play"}},
      socket = %{ assigns: %{ current_user: current_user, invite_from: invite_from}}
  ) do
    # accept invite:  go to "play" liveview to begin game.
    # broadcast message that other player will recieve and navigate to same game
    game_id = :rand.uniform(999999)
    broadcast_message!("accept_invite",
      %{ to: invite_from, from: current_user, game_id: game_id})

    {:noreply,
      redirect(socket, to: Routes.live_path(socket, ClientAppWeb.PlayLive, game_id))}
  end

  def handle_info(
    {ModalLive,
    :button_clicked,
    %{action: "decline"}},
    socket
  ) do
     # don't want to play. not informing the guy who sent the invite, just ignoring
    {:noreply,
      push_patch(socket,
        to: Routes.live_path(socket, ClientAppWeb.LobbyLive),
        replace: true
      )}
  end

  def handle_info(
    %{event: "accept_invite", payload: %{to: to, game_id: game_id}},
    %{assigns: %{current_user: current_user}} = socket
  ) do
    case to do
      ^current_user ->
        # get notified our invite has been accepted. Redirect to game that
        # invitee has setup
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

  defp last_path_segment(uri) do
    uri
    |> URI.parse()
    |> Map.get(:path)
    |> String.split("/", trim: true)
    |> List.first()
  end

end
