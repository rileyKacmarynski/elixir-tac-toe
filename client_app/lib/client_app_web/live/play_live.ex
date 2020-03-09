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
    %{assigns: %{topic: topic}} = socket
  ) do
    users =
      Presence.list(topic)
      |> Enum.map(fn {username, _data} -> username end)

      # we should be able to send(self, ...) to send this process a message.
      # we can catch that message in a handle_info callback like we did with the
      # modal in the Lobby liveview.
      # that handle_info callback will have the socket. We'll have the users
      # there and can get/create (we'll have both players and an id. )

      {:noreply, assign(socket, users: users )}
  end
end
