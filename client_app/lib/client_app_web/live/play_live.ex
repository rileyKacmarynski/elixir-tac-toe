defmodule ClientAppWeb.PlayLive do
  use Phoenix.LiveView

  alias ClientAppWeb.Router.Helpers, as: Routes
  alias ClientAppWeb.Presence


  @topic "play:"

  def mount(%{"game" => game_id}, session, socket) do
    {:ok,
      socket
      |> assign(:current_user, Map.fetch!(session, "current_user"))
      |> assign(game_id: game_id)
      |> setup_presence()}
  end

  def render(assigns) do
    IO.inspect(assigns)
    Phoenix.View.render(ClientAppWeb.PageView, "play.html", assigns)
  end

  defp setup_presence(
    socket = %{ assigns: %{ current_user: current_user, game_id: game_id }}
  ) do
    topic = @topic <> to_string(game_id)
    ClientAppWeb.Endpoint.subscribe(topic)

    Presence.track(
      self(),
      @topic,
      current_user,
      %{}
    )

    socket
  end

end
