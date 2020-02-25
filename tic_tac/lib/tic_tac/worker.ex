defmodule TicTac.Worker do

  use GenServer, restart: :transient

  def start_link(opts) do
    {name, opts} = Keyword.pops(opts, :name)
    GenServer.start_link(__Module__, opts, name: name)
  end

  def init(opts) do
    #initialize game state here

    state = %{}

    {:ok, state}
  end
end
