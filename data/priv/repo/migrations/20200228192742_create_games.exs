defmodule Data.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :game_id, :string
      add :state, :map
    end
  end
end
