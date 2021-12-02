defmodule Sol do
  alias Sol.{Move, Position}

  @path Path.join(~w(priv input.txt))

  def part_1(file \\ @path), do: apply_moves(file)

  def part_2(file \\ @path), do: apply_moves(file, movement_strategy: Sol.MovementStrategies.Aim)

  defp apply_moves(file, opts \\ []) do
    file
    |> File.stream!()
    |> Stream.map(&Move.from_string/1)
    |> Enum.reduce(Position.new(), fn %Move{} = move, %Position{} = pos ->
      Position.apply(pos, move, opts)
    end)
    |> Position.result()
  end
end
