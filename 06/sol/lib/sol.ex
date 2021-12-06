defmodule Sol do
  @moduledoc """
  Documentation for `Sol`.
  """

  @input "4,5,3,2,3,3,2,4,2,1,2,4,5,2,2,2,4,1,1,1,5,1,1,2,5,2,1,1,4,4,5,5,1,2,1,1,5,3,5,2,4,3,2,4,5,3,2,1,4,1,3,1,2,4,1,1,4,1,4,2,5,1,4,3,5,2,4,5,4,2,2,5,1,1,2,4,1,4,4,1,1,3,1,2,3,2,5,5,1,1,5,2,4,2,2,4,1,1,1,4,2,2,3,1,2,4,5,4,5,4,2,3,1,4,1,3,1,2,3,3,2,4,3,3,3,1,4,2,3,4,2,1,5,4,2,4,4,3,2,1,5,3,1,4,1,1,5,4,2,4,2,2,4,4,4,1,4,2,4,1,1,3,5,1,5,5,1,3,2,2,3,5,3,1,1,4,4,1,3,3,3,5,1,1,2,5,5,5,2,4,1,5,1,2,1,1,1,4,3,1,5,2,3,1,3,1,4,1,3,5,4,5,1,3,4,2,1,5,1,3,4,5,5,2,1,2,1,1,1,4,3,1,4,2,3,1,3,5,1,4,5,3,1,3,3,2,2,1,5,5,4,3,2,1,5,1,3,1,3,5,1,1,2,1,1,1,5,2,1,1,3,2,1,5,5,5,1,1,5,1,4,1,5,4,2,4,5,2,4,3,2,5,4,1,1,2,4,3,2,1"

  def part_1(input \\ @input), do: compute(input, 80)

  def part_2(input \\ @input), do: compute(input, 256)

  defp compute(input, cycle_count) do
    timer_map = parse(input)

    Enum.reduce(1..cycle_count, timer_map, fn _, acc -> tick(acc) end)
    |> Map.values()
    |> Enum.sum()
  end

  defp parse(input) do
    input
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(%{}, fn timer, acc ->
      Map.update(acc, timer, 1, &(&1 + 1))
    end)
  end

  defp tick(timer_map) do
    timer_map
    |> Enum.flat_map(fn
      {0, count} -> [{6, count}, {8, count}]
      {timer, count} -> [{timer - 1, count}]
    end)
    |> List.flatten()
    |> Enum.reduce(%{}, fn {timer, count}, acc ->
      Map.update(acc, timer, count, &(&1 + count))
    end)
  end
end
