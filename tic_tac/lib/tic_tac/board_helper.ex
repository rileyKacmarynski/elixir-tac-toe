defmodule TicTac.BoardHelper do
  def fill_flat() do
    fill()
    |> Enum.flat_map(&(&1))
  end

  defp fill() do
    for x <- 1..3 do
      for y <- 1..3 do
        {x, y}
      end
    end
  end
end
