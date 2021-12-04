defmodule Sol do
  @moduledoc """
  Documentation for `Sol`.
  """

  alias Sol.{Board, Game, Input}

  @path Path.join(~w(priv input.txt))

  def part_1(path \\ @path) do
    game =
      Game
      |> struct!(Input.parse(path))
      |> Game.play_until_winners()

    unmarked_sum =
      game.winning_boards
      |> hd()
      |> Board.unmarked_sum()

    unmarked_sum * game.last_announced
  end
end
