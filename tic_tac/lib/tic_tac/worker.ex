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
    # Maybe figure out some way to persist the previous state
    # when something goes wrong. The current state might be why something happended
    # in the first place

    {:ok, Game.new_game(id, players), @timeout}
  end

  def handle_call({:make_move, player, move}, _from, game) do
    {game, client_state} = Game.make_move(game, player, move)
    # probably put code to persist game state here.

    {:reply, client_state, game, @timeout}
  end

  def handle_call(:get_game, _from, game) do
    {new_game, client_state} = Game.get_client_state(game)
    {:reply, client_state, new_game, @timeout}
  end

  def handle_info(:timeout, _) do
		{:stop, :normal, []}
	end

  defp handle_persistence(game = %{game_state: :playing}) do
    # persist game to disk
  end

  defp handle_persistence(game = %{game_state: state}) when state in [:won, :tied] do
    # game is over. Delete game
  end
end
