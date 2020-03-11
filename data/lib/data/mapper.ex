defmodule Mapper do
  def map_to_output(game = %{ "board" => %{ "o" => o, "x" => x, "free" => free}}) do
    tuple_o = to_tuple_list(o) |> MapSet.new()
    tuple_x = to_tuple_list(x) |> MapSet.new()
    tuple_free = to_tuple_list(free) |> MapSet.new()

    game
    |> keys_to_atoms()
    |> Map.put(:board, %{ :free => tuple_free, :o => tuple_o, :x => tuple_x })
    |> Map.put(:turn, Map.fetch!(game, "turn") |> String.to_atom)
    |> Map.put(:game_state, Map.fetch!(game, "game_state") |> String.to_atom)
  end

  defp to_tuple_list(l) do
    Enum.map(l, fn [h | t] -> {h, List.first(t)} end)
  end

  def keys_to_atoms(string_key_map) when is_map(string_key_map) do
    for {key, val} <- string_key_map, into: %{}, do: {String.to_atom(key), keys_to_atoms(val)}
  end
  def keys_to_atoms(value), do: value
end
