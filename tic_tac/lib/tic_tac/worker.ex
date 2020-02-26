defmodule TicTac.Worker do

  use GenServer, restart: :transient

  def start_link(opts) do
    {name, opts} = Keyword.pop(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def init(opts) do
    #initialize game state here

    state = %{}

    {:ok, state}
  end
end
