defmodule Sol.Game do
  alias Sol.Board

  defstruct [:numbers, :boards, :last_announced, winning_boards: []]

  def new(numbers, boards) do
    %__MODULE__{numbers: numbers, boards: boards}
  end

  def play_until_winners(%__MODULE__{numbers: [], winning_boards: []} = game), do: game

  def play_until_winners(%__MODULE__{numbers: _, winning_boards: winners} = game)
      when length(winners) > 0,
      do: game

  def play_until_winners(%__MODULE__{} = game) do
    game
    |> announce_next_number()
    |> play_until_winners()
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
