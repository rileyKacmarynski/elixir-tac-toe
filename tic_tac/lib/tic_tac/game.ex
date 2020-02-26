defmodule TicTac.Game do

  alias TicTac.BoardHelper

  defstruct(
    id: nil,
    turn: nil,
    game_state: :start,
    players: nil,
    winner: nil,
    board: %{
      :free => BoardHelper.fill() |> MapSet.new,
      :x => MapSet.new,
      :o => MapSet.new
    }
  )

  @doc """

  """
  def new_game(game_id, {p1_id, p2_id}) do
    %TicTac.Game{
      id: game_id,
      turn: pick_first(),
      players: %{ :x => p1_id, :o => p2_id }
    }
  end

  def make_move(game = %{ turn: turn, players: players }, player, move) do
    case Map.get(players, turn) do
      ^player -> make_move(game, move)
      _ -> {:error, :wrong_turn}
    end
  end




  defp make_move(game, move) do
    game
    |> mark_move(move)
    |> maybe_won
    |> switch_turn
  end

  def mark_move(game = %{ board: board, turn: turn}, move) do
    new_board =
      %{board |
        :free => MapSet.delete(board.free, move),
        turn => MapSet.put(board[turn], move)
      }

    Map.put(game, :board, new_board)
  end

  defp switch_turn(game = %{turn: :x}), do: Map.put(game, :turn, :o)
  defp switch_turn(game = %{turn: :o}), do: Map.put(game, :turn, :x)

  defp maybe_won(game = %{ board: board, turn: turn }) do
    maybe_won(game, BoardHelper.check_win(board[turn]))
  end

  defp maybe_won(game = %{ players: players, turn: turn }, true) do
    Map.put(game, :winner, players[turn])
  end

  # defp finish_turn(game, false) do
  #   case MapSet.size(game.board.free) do
  #     0 -> Map.put(game, :game_state, :tied)
  #     _ -> game
  #   end
  # end

  defp pick_first(), do: pick_first(:rand.uniform(2))
  defp pick_first(1), do: :x
  defp pick_first(2), do: :o

end
