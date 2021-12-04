defmodule Sol do
  defdelegate part_1(), to: Sol.Part1, as: :run
  defdelegate part_1(path), to: Sol.Part1, as: :run
end
