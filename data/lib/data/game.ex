defmodule Data.Game do
  use Ecto.Schema

  require Ecto.Query

  alias Data.Repo
  alias Data.Game

  schema "games" do
    field :game_id, :string
    field :state, :map
  end

  def save_game(game_state = %{game_id: id }) do
    case Repo.get_by(Game, game_id: id) do
      nil -> %Game{ :game_id => id, :state => game_state}
      game -> game
    end
    |> changeset(%{state: game_state})
    |> Repo.insert_or_update
  end

  def delete_game(id) do
    Repo.get_by!(Game, game_id: id)
    |> Repo.delete
  end

  def get_game(id) do
    case Repo.get_by(Game, game_id: id) do
      nil -> nil
      game -> game
        |> Map.from_struct
        |> Map.get(:state)
        |> Mapper.map_to_output()
    end
  end

  defp changeset(game, params) do
    IO.puts("changeset")
    IO.inspect(game)
    IO.inspect(params)
    game
    |> Ecto.Changeset.cast(params, [:game_id, :state])
    |> Ecto.Changeset.validate_required([:game_id])
  end

end
