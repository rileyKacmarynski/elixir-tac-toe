defmodule ClientAppWeb.PlayLive do
  use Phoenix.LiveView

  alias ClientAppWeb.Router.Helpers, as: Routes
  alias ClientAppWeb.Presence

  def mount(%{"game" => game_id}, session, socket) do
    IO.inspect(socket)

    socket = socket
    |> assign(:current_user, Map.fetch!(session, "current_user"))
    |> assign(game_id: game_id, users: [])
    |> setup_presence()

    {:ok, socket }
  end

  def render(assigns) do
    Phoenix.View.render(ClientAppWeb.PageView, "play.html", assigns)
  end

  defp setup_presence(
    socket = %{ assigns: %{ current_user: current_user, game_id: game_id }}
  ) do
    topic = "play:" <> to_string(game_id)
    ClientAppWeb.Endpoint.subscribe(topic)

    Presence.track(
      self(),
      topic,
      current_user,
      %{}
    )

    assign(socket, topic: topic)
  end

  def handle_info(
    %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
    %{assigns: %{topic: topic, game_id: id}} = socket
  ) do
    users =
      Presence.list(topic)
      |> Enum.map(fn {username, _data} -> username end)

    socket =
      assign(users: users)
      |> maybe_start_game()

      IO.inspect(socket.assigns)
      {:noreply, socket}
  end

  defp maybe_start_game(
    %{assigns: %{game_id: id, users: users}} = socket
  ) do
      # if we have two users, begin/get game
      if Enum.count(users) == 2 do
        [p1 | [p2 | tail]] = users
        assign(socket, game: TicTac.start(id, p1, p2))
      else
        socket
      end
  end
end
