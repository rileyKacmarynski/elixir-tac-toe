defmodule TicTac do

  @registry TicTac.Registry
  @supervisor TicTac.WorkerSupervisor

  @moduledoc """
  Documentation for TicTac.
  """

  @doc """
  starts a new tic-tac-toe GenServer
  """
  def start do
    opts = [
      id: :some_id,
      name: via_tuple(:some_id)
    ]

    DynamicSupervisor.start_child(@supervisor, {TicTac.Worker, opts})
  end

  defp via_tuple(id), do: {:via, Registry, {@registry, id}}
end
