defmodule Data do
  alias Data.Game

  defdelegate save_game(game), to: Game
  defdelegate delete_game(game_id), to: Game
  defdelegate get_game(game_id), to: Game
end
