defmodule GameTest do
  use ExUnit.Case

  alias TicTac.Game

  test "game starts" do
    game = Game.new_game("123", {"p1", "p2"})

    assert game.game_state == :playing
    assert map_size(game.players) == 2
  end

  test "game state isn't change when game is over" do
    game = Game.new_game("123", {"p1", "p2"})
    game = Map.put(game, :game_state, :tied)
    game = Map.put(game, :turn, :x)

    assert {^game, _} = Game.make_move(game, "p1", {1, 1})
  end

  test "player goes out of turn" do
    game = Game.new_game("123", {"p1", "p2"})
    game = Map.put(game, :turn, :x)

    assert {:error, :wrong_turn} = Game.make_move(game, "p2", {1, 1})
  end

  test "player plays in free spot" do
    game = Game.new_game("123", {"p1", "p2"})
    game = Map.put(game, :turn, :x)

    {game, _} = Game.make_move(game, "p1", {1, 1})

    assert MapSet.member?(game.board.free, {1, 1}) == false
    assert MapSet.member?(game.board.x, {1, 1}) == true
  end

  test "game switches turn" do
    game = Game.new_game("123", {"p1", "p2"})
    game = Map.put(game, :turn, :x)

    {game, _} = Game.make_move(game, "p1", {1, 1})

    assert game.turn == :o
  end

  test "player wins game" do
    game = Game.new_game("123", {"p1", "p2"})
    game = Map.put(game, :turn, :x)

    #it might be easier to just change the maps, but let's play out a full game
    {game, _} = Game.make_move(game, "p1", {1, 1})
    {game, _} = Game.make_move(game, "p2", {1, 2})
    {game, _} = Game.make_move(game, "p1", {2, 1})
    {game, _} = Game.make_move(game, "p2", {1, 3})
    {game, _} = Game.make_move(game, "p1", {3, 1})

    assert game.game_state == :won
    assert game.winner == "p1"
  end

  test "tie game" do
    game = Game.new_game("123", {"p1", "p2"})
    game = Map.put(game, :turn, :x)

    # make the game look like this
    # x  o  x
    # o  x  x
    # o  x  o
    {game, _} = Game.make_move(game, "p1", {1, 3})
    {game, _} = Game.make_move(game, "p2", {2, 3})
    {game, _} = Game.make_move(game, "p1", {3, 3})
    {game, _} = Game.make_move(game, "p2", {1, 2})
    {game, _} = Game.make_move(game, "p1", {2, 2})
    {game, _} = Game.make_move(game, "p2", {3, 1})
    {game, _} = Game.make_move(game, "p1", {2, 1})
    {game, _} = Game.make_move(game, "p2", {1, 1})
    {game, _} = Game.make_move(game, "p1", {3, 2})

    assert game.game_state == :tied
    assert game.winner == nil
  end

end
