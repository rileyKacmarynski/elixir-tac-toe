defmodule TicTac.Worker do

  use GenServer, restart: :transient

  alias TicTac.Game

  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    #initialize GenServer state here
    players = Keyword.get(opts, :players)
    id = Keyword.get(opts, :id)

    {:ok, Game.new_game(id, players)}
  end
end
