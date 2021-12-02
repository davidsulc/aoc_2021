defmodule Sol do
  alias Sol.{Move, Position}

  @path Path.join(~w(priv input.txt))

  def part_1(file \\ @path), do: apply_moves(file)

  def part_2(file \\ @path), do: apply_moves(file, true)

  defp apply_moves(file, use_aim? \\ false) do
    file
    |> File.stream!()
    |> Stream.map(&Move.from_string/1)
    |> Enum.reduce(Position.new(), fn %Move{} = move, %Position{} = pos ->
      Position.apply(pos, move, use_aim?)
    end)
    |> Position.result()
  end
end
