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

  @doc """

  """
  def new_game(game_id, {p1_id, p2_id}) do
    %TicTac.Game{
      id: game_id,
      turn: pick_first()
    }
  end

  defp pick_first(), do: pick_first(:rand.uniform(2))
  defp pick_first(1), do: :x
  defp pick_first(2), do: :o

end
