defmodule TicTac do

  @registry TicTac.Registry
  @supervisor TicTac.WorkerSupervisor

  @moduledoc """
  Documentation for TicTac.
  """

  @doc """
    checks to see if a game with the given id exists.
    If it does, return that one, otherwise start a new game
  """
  def start(id, p1, p2) do
    case lookup_game(id) do
      {:error, :not_found} -> create(id, p1, p2)
      pid -> call(pid, :get_game)
    end
  end

  defp create(id, p1, p2) do
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

  def lookup_game(id) do
    case Registry.lookup(@registry, id) do
      [{pid, _}] -> pid
      [] -> {:error, :not_found} # code to try to grab from db could go here.
    end
  end

  def kill_game(id) do
    lookup_game(id)
    |> Process.exit(:kill)
  end

  defp call({:error, :not_found}, _opts), do: IO.puts("Unable to find game.")
  defp call(pid, opts), do: GenServer.call(pid, opts)

  defp via_tuple(id), do: {:via, Registry, {@registry, id}}
end
