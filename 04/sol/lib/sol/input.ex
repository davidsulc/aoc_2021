defmodule Sol.Input do
  alias Sol.Board

  def parse(path) do
    [numbers | boards] =
      path
      |> File.read!()
      |> String.split("\n\n")

    %{numbers: parse_numbers(numbers), boards: parse_boards(boards)}
  end

  defp parse_numbers(numbers) do
    numbers
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_boards(boards) do
    Enum.map(boards, &Board.parse/1)
  end
end
