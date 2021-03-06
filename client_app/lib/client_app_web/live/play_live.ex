defmodule ClientAppWeb.PlayLive do
  use Phoenix.LiveView

  alias ClientAppWeb.Router.Helpers, as: Routes
  alias ClientAppWeb.Presence

  def mount(%{"game" => game_id}, session, socket) do
    IO.inspect(socket)

    socket = socket
    |> assign(:current_user, Map.fetch!(session, "current_user"))
    |> assign(game_id: game_id, users: [], game: nil)
    |> setup_presence()

    {:ok, socket }
  end

  def render(assigns) do
    Phoenix.View.render(ClientAppWeb.PageView, "play.html", assigns)
  end

  def handle_event("play",
  %{"spot" => spot},
  %{assigns: %{current_user: current_user, game: game, topic: topic}} = socket
  ) do
    case Map.get(game.players, game.turn) do
      ^current_user ->
        new_game = play_turn(game.game_id, current_user, get_coord(spot))
        IO.puts("new_game")
        IO.inspect(new_game)
        ClientAppWeb.Endpoint.broadcast_from!(
          self(),
          topic,
          "finished_turn",
          %{game: new_game}
        )

        {:noreply, assign(socket, game: new_game)}
      _ ->
        IO.puts("not your turn")
        {:noreply, socket}
    end
  end

  def handle_info(%{event: "finished_turn", payload: %{game: game}}, socket) do
    {:noreply, assign(socket, game: game)}
  end

  def handle_info(
    %{event: "presence_diff"},
    %{assigns: %{topic: topic, game_id: id}} = socket
  ) do
    users =
      Presence.list(topic)
      |> Enum.map(fn {username, _data} -> username end)

    socket = socket
      |> assign(users: users)
      |> maybe_start_game()

      {:noreply, socket}
  end

  defp play_turn(game_id, current_user, spot) do
   TicTac.make_move(game_id, current_user, spot)
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

  defp maybe_start_game(
    %{assigns: %{game_id: id, users: users}} = socket
  ) do
      # if we have two users, begin/get game
      if Enum.count(users) == 2 do
        [p1 | [p2 | _tail]] = users
        assign(socket, game: TicTac.start(id, p1, p2))
      else
        socket
      end
  end

  defp get_coord("1"), do: {1, 1}
  defp get_coord("2"), do: {2, 1}
  defp get_coord("3"), do: {3, 1}
  defp get_coord("4"), do: {1, 2}
  defp get_coord("5"), do: {2, 2}
  defp get_coord("6"), do: {3, 2}
  defp get_coord("7"), do: {1, 3}
  defp get_coord("8"), do: {2, 3}
  defp get_coord("9"), do: {3, 3}
end
