defmodule TicTac do

  @registry TicTac.Registry
  @supervisor TicTac.WorkerSupervisor

  @moduledoc """
  Documentation for TicTac.
  """

  @doc """
  starts a new tic-tac-toe GenServer
  """
  def start(p1, p2) do
    id = UUID.uuid1()
    opts = [
      id: id,
      players: {p1, p2},
      name: via_tuple(id)
    ]

    DynamicSupervisor.start_child(@supervisor, {TicTac.Worker, opts})
    {:ok, id}
  end

  def make_move(game_id, player, move) do
    game_id
    |> lookup_game
    |> call({:make_move, player, move})
  end

  def get_game(game_id) do
    game_id
    |> lookup_game
    |> call(:get_game)
  end

  def lookup(id), do: Registry.lookup(@registry, id)

  defp lookup_game(id) do
    case Registry.lookup(@registry, id) do
      [{pid, _}] -> pid
      [] -> {:error, :not_found} # code to try to grab from db could go here.
    end
  end

  defp call({:error, :not_found}, _opts), do: IO.puts("Unable to find game.")
  defp call(pid, opts), do: GenServer.call(pid, opts)

  defp via_tuple(id), do: {:via, Registry, {@registry, id}}
end
