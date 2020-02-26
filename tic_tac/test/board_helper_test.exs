defmodule BoardHelperTest do
  use ExUnit.Case
  doctest TicTac.BoardHelper

  alias TicTac.BoardHelper

  test "count vertical line win" do
    spaces = [{2, 1}, {2, 2}, {3, 1}, {2,3}]

    assert BoardHelper.check_win(spaces) == true
  end

  test "count horizontal line win" do
    spaces = [{1, 2}, {3, 2}, {3, 1}, {2,2}]

    assert BoardHelper.check_win(spaces) == true
  end

  test "count / diagonal line win" do
    spaces = [{1, 2}, {1, 1}, {3, 3}, {2,2}]

    assert BoardHelper.check_win(spaces) == true
  end

  test "count \\ diagonal line win" do
    spaces = [{1, 3}, {3, 2}, {3, 1}, {2,2}]

    assert BoardHelper.check_win(spaces) == true
  end

  test "return false for no win" do
    spaces = [{1, 3}, {3, 2}]

    assert BoardHelper.check_win(spaces) == false
  end
end
