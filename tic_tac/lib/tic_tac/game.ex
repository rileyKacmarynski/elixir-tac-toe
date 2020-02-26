defmodule TicTac.Game do

  alias TicTac.BoardHelper

  defstruct(
    id: nil,
    turn: nil,
    game_state: :start,
    board: %{
      :free => BoardHelper.fill_flat() |> MapSet.new,
      :x => MapSet.new,
      :o => MapSet.new
    }
  )

  def new_game() do
    %TicTac.Game{
      id: UUID.uuid1(),
      turn: pick_first()
    }
  end

  defp pick_first() do
    case :rand.uniform(2) do
      1 -> :x
      2 -> :o
    end
  end

end
