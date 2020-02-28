defmodule TicTac.Worker do

  use GenServer, restart: :transient

  alias TicTac.Game

  @timeout 300_000 # 5 minutes: 5 * 60 * 1_000

  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    #initialize GenServer state here
    players = Keyword.get(opts, :players)
    id = Keyword.get(opts, :id)

    # we need to see if there's a game stored in the db and use that state
    case Data.get_game(id) do
      nil -> {:ok, Game.new_game(id, players), @timeout}
      game -> {:ok, game, @timeout}
    end
  end

  def handle_call({:make_move, player, move}, _from, game) do
    {game, client_state} = Game.make_move(game, player, move)
    # probably put code to persist game state here.
    case game.game_state do
      :playing ->
        save_game(game)
        {:reply, client_state, game, @timeout}
      state when state in [:won, :tied] ->
        delete_game(game)
        {:stop, :normal, client_state, game}
    end
  end

  def handle_call(:get_game, _from, game) do
    {new_game, client_state} = Game.get_client_state(game)
    {:reply, client_state, new_game, @timeout}
  end

  def handle_info(:timeout, _) do
		{:stop, :normal, []}
	end

  defp save_game(game) do
    Map.from_struct(game)
    |> Data.save_game
  end

  defp delete_game(%{game_id: game_id}) do
    Data.delete_game(game_id)
  end
end
