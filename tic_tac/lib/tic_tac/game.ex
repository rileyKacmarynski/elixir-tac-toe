defmodule TicTac.Game do

  alias TicTac.BoardHelper

  defstruct(
    id: nil,
    turn: nil,
    game_state: :playing,
    players: nil,
    winner: nil,
    board: %{
      :free => BoardHelper.fill() |> MapSet.new,
      :o => MapSet.new,
      :x => MapSet.new,
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
      ^player -> make_move(game, move) |> get_client_state
      _ -> {:error, :wrong_turn}
    end
  end

  # The implementation of :board works great for handling game interactions in code,
  # but it would be eaiser to send a 2D list representation back to the client where each
  # index [x][y] has a value of :x, :o, or :free.
  # the actual state will also be returned so our GenServer can keep a hold of that
  def get_client_state(game) do
    client_state = %{
      :id => game.id,
      :game_state => game.game_state,
      :players => game.players,
      :winner => game.winner,
      :board => BoardHelper.fill_matrix(game.board)
    }

    {game, client_state}
  end

  defp make_move(game = %{ game_state: state }, _move) when state in [:won, :tied] do
    game
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
    |> Map.put( :game_state, :won)
  end


  defp maybe_won(game, false) do
    case MapSet.size(game.board.free) do
      0 -> Map.put(game, :game_state, :tied)
      _ -> game
    end
  end

  defp pick_first(), do: pick_first(:rand.uniform(2))
  defp pick_first(1), do: :x
  defp pick_first(2), do: :o

end
