defmodule Sol do
  alias Sol.{Move, Position}

  @path Path.join(~w(priv input.txt))

  def part_1(file \\ @path) do
    file
    |> File.stream!()
    |> Stream.map(&Move.from_string/1)
    |> Enum.reduce(Position.new(), fn %Move{} = move, %Position{} = pos ->
      Position.apply(pos, move)
    end)
    |> Position.result()
  end
end
