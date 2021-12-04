defmodule Sol do
  @moduledoc """
  Documentation for `Sol`.
  """

  alias Sol.{Board, Game, Input}

  @path Path.join(~w(priv input.txt))

  def part_1(path \\ @path) do
    resolve_game(
      path,
      fn
        %Game{winning_boards: [_ | _]} -> true
        _ -> false
      end
    )
  end

  def part_2(path \\ @path) do
    resolve_game(
      path,
      fn
        %Game{boards: boards, winning_boards: winners}
        when length(boards) == length(winners) ->
          true

        _ ->
          false
      end
    )
  end

  defp resolve_game(path, condition) do
    game =
      Game
      |> struct!(Input.parse(path))
      |> Game.play_until(condition)

    unmarked_sum =
      game.winning_boards
      |> hd()
      |> Board.unmarked_sum()

    unmarked_sum * game.last_announced
  end
end
