defmodule TicTac.BoardHelper do
  @moduledoc"""
    Helper functions for working with the tic-tac-toe board.
  """

  def fill() do
    for x <- 1..3,
        y <- 1..3 do
          {x, y}
    end
  end

  def fill_matrix(%{ free: free, o: o, x: x }) do
    for j <- 1..3,
        k <- 1..3 do
         cond do
          MapSet.member?(free, {j, k}) == true -> :free
          MapSet.member?(x, {j, k}) == true -> :x
          MapSet.member?(o, {j, k}) == true -> :o
      end
    end
  end

  @doc """
    A player's taken `spaces` are passed in as an array of tuples
    ex. [{1, 1}, {1, 2}, {1,3}, {3, 1}]
    Returns  `true` or `false`
  """
  def check_win(spaces) do
    check_win(spaces, fn {x, _y} -> x end) or
    check_win(spaces, fn {_x, y} -> y end) or
    Enum.count(spaces, fn {x, y} -> x == y end) == 3 or
    Enum.count(spaces, fn {x, y} -> ((x + y) / 2) == 2 end) == 3
  end


  # When a player wins with a vertical or horizontal line
  # there will be 3 tuples with the same x or y value.
  # This function is used to count the number of tuples that share
  # x or y values and returns true if it finds 3.
  defp check_win(spaces, f) do
    for n <- 1..3 do
      Enum.count(spaces, fn t -> f.(t) == n end) == 3
    end
    |> Enum.any?(&(&1 == true))
  end
end
