defmodule Sol.Game do
  alias Sol.Board

  defstruct [:numbers, :boards, :last_announced, winning_boards: []]

  def new(numbers, boards) do
    %__MODULE__{numbers: numbers, boards: boards}
  end

  def play_until(%__MODULE__{} = game, condition), do: play_until(:continue, game, condition)

  def play_until(:halt, %__MODULE__{} = game, _condition), do: game

  def play_until(:continue, %__MODULE__{} = game, condition) do
    game = announce_next_number(game)

    continue? =
      cond do
        condition.(game) -> :halt
        length(game.numbers) == 0 -> :halt
        true -> :continue
      end

    play_until(continue?, game, condition)
  end

  defp announce_next_number(%__MODULE__{} = game) do
    [number | rest] = game.numbers

    %{boards: boards, winners: winners} =
      Enum.reduce(game.boards, %{boards: [], winners: game.winning_boards}, fn
        %Board{winner: true} = board, acc ->
          %{acc | boards: [board | acc.boards]}

        %Board{winner: false} = board, acc ->
          board = Board.mark(board, number)

          winners =
            case board.winner do
              false -> acc.winners
              true -> [board | acc.winners]
            end

          %{acc | boards: [board | acc.boards], winners: winners}
      end)

    %{
      game
      | numbers: rest,
        last_announced: number,
        boards: Enum.reverse(boards),
        winning_boards: winners
    }
  end
end
