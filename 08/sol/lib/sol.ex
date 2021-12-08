defmodule Sol do
  @path Path.join(~w(priv input.txt))

  defp pase_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.split("|", trim: true)
    |> parse()
  end

  defp parse([patterns, output]) do
    {parse_group(patterns), parse_group(output)}
  end

  defp parse_group(group) do
    String.split(group, " ", trim: true)
  end

  def part_1(path \\ @path) do
    path
    |> pase_input()
    |> Enum.map(fn {_, output} -> output end)
    |> Enum.reduce(0, fn patterns, acc ->
      acc + matching_count(patterns)
    end)
  end

  defp matching_count(patterns) do
    Enum.reduce(patterns, 0, fn pattern, acc ->
      case String.length(pattern) do
        l when l in [2, 3, 4, 7] -> acc + 1
        _ -> acc
      end
    end)
  end
end
