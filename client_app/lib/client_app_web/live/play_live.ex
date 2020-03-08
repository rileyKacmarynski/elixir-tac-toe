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

    # we are going to have to check to see if the game with that id has been started
    # if it has we can get the game, if it hasn't we'll start it and get the game.
    # This will ensure only one user start the game

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
    %{assigns: %{topic: topic}} = socket
  ) do
    users =
      Presence.list(topic)
      |> Enum.map(fn {username, _data} -> username end)

      # if both players have joined, start the game.

      # IO.puts("diff called for user #{socket.assigns.current_user}")
      # IO.inspect(users)
      # IO.inspect(joins)

      {:noreply, assign(socket, users: users )}
  end
end
