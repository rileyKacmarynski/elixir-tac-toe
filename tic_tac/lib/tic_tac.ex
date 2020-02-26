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
  end

  defp via_tuple(id), do: {:via, Registry, {@registry, id}}
end
