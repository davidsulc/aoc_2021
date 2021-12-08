defmodule Sol do
  @path Path.join(~w(priv input.txt))

  defp parse_input(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    line
    |> String.split("|", trim: true)
    |> parse()
  end

  defp parse([patterns, output]) do
    {parse_group(patterns), parse_group(output)}
  end

  defp parse_group(group) do
    group
    |> String.split(" ", trim: true)
    |> Enum.map(&parse_pattern/1)
  end

  def parse_pattern(pattern) do
    pattern
    |> String.split("", trim: true)
    |> Enum.map(&:"#{&1}")
  end

  def part_1(path \\ @path) do
    path
    |> parse_input()
    |> Enum.map(fn {_, output} -> output end)
    |> Enum.reduce(0, fn patterns, acc ->
      acc + matching_count(patterns)
    end)
  end

  def part_2(path \\ @path) do
    path
    |> parse_input()
    |> Enum.map(&determine_number/1)
    |> Enum.sum()
  end

  defp matching_count(patterns) do
    Enum.reduce(patterns, 0, fn pattern, acc ->
      case length(pattern) do
        l when l in [2, 3, 4, 7] -> acc + 1
        _ -> acc
      end
    end)
  end

  def determine_number({patterns, outputs}) do
    config = resolve_config(patterns)

    outputs
    |> Enum.map(&display(&1, config))
    |> Enum.map(&Integer.to_string/1)
    |> Enum.join("")
    |> String.to_integer()
  end

  # def sum_output(output, config) when is_binary(output) do
  #   output
  #   |> parse_group()
  #   |> sum_output(config)
  # end

  # def sum_output(output, config) when is_list(output) do
  #   output
  #   |> IO.inspect()
  #   |> Enum.map(&display(&1, config))
  #   |> Enum.sum()
  # end

  def resolve_config(patterns) when is_binary(patterns) do
    patterns
    |> parse_group()
    |> resolve_config()
  end

  def resolve_config(patterns) when is_list(patterns) do
    patterns_by_length =
      patterns
      |> Enum.map(&MapSet.new/1)
      |> Enum.group_by(&MapSet.size/1)

    initial_config()
    |> solve_for_1(patterns_by_length)
    |> solve_for_7(patterns_by_length)
    |> solve_for_4(patterns_by_length)
    |> solve_for_2_3_5(patterns_by_length)
    |> solve_for_0_6_9(patterns_by_length)
    |> finalize()
  end

  defp finalize(map) do
    map
    |> Enum.map(fn {k, [v]} -> {k, v} end)
    |> Enum.into(%{})
  end

  defp initial_config() do
    for x <- 0..6, into: %{} do
      {x, ~w(a b c d e f g)a}
    end
  end

  # the segments for "1" will only be the 2 on the right side
  # => the 2 signals for "1" (which is the only number with only 2 segments) are the only options
  # for segments 2 and 5, and therefore can't be used by other segments
  defp solve_for_1(config, patterns) do
    segments = hd(patterns[2])

    Enum.map(config, fn
      {k, _v} when k in [2, 5] -> {k, MapSet.to_list(segments)}
      {k, v} -> {k, Enum.reject(v, &MapSet.member?(segments, &1))}
    end)
  end

  defp solve_for_7(config, patterns) do
    segments = hd(patterns[3])

    Enum.map(config, fn
      {k, v} when k in [0, 2, 5] -> {k, Enum.filter(v, &MapSet.member?(segments, &1))}
      {k, v} -> {k, Enum.reject(v, &MapSet.member?(segments, &1))}
    end)
  end

  defp solve_for_4(config, patterns) do
    segments = hd(patterns[4])

    Enum.map(config, fn
      {k, v} when k in [1, 2, 3, 5] -> {k, Enum.filter(v, &MapSet.member?(segments, &1))}
      {k, v} -> {k, Enum.reject(v, &MapSet.member?(segments, &1))}
    end)
  end

  # All horizontal segments will appear in all of 2, 3, and 5
  # => eliminate those signals from other segments, and keep only
  # the common signals for the horizontal segments
  defp solve_for_2_3_5(config, patterns) do
    common_segments = Enum.reduce(patterns[5], &MapSet.intersection/2)

    Enum.map(config, fn
      {k, v} when k in [0, 3, 6] -> {k, Enum.filter(v, &MapSet.member?(common_segments, &1))}
      {k, v} -> {k, Enum.reject(v, &MapSet.member?(common_segments, &1))}
    end)
  end

  # The segments that aren't ALL of 0, 6, 9 will be numbers 2, 3, 4 (the "diagonal").
  # By computing the set of segments not present in all of those, we can determine
  # the signal for segments 2 and 5 (they both have 2 options, as determined by solve_for_1):
  # segment 2 will be the value in the set, while segment 5 will be the one missing from the set
  defp solve_for_0_6_9(config, patterns) do
    common_segments = Enum.reduce(patterns[6], &MapSet.intersection/2)

    uncommon_segments =
      patterns[6]
      |> Enum.map(&MapSet.difference(&1, common_segments))
      |> Enum.reduce(&MapSet.union/2)

    Enum.map(config, fn
      {2, v} -> {2, Enum.filter(v, &MapSet.member?(uncommon_segments, &1))}
      {5, v} -> {5, Enum.reject(v, &MapSet.member?(uncommon_segments, &1))}
      pair -> pair
    end)
  end

  def display(pattern, config) do
    pattern
    |> render(config)
    |> convert()
  end

  defp render(pattern, config) do
    segments = MapSet.new(pattern)

    for x <- 0..6 do
      case MapSet.member?(segments, Map.get(config, x)) do
        true -> 1
        false -> 0
      end
    end
  end

  # tuple of segments, starting at top and moving down, from left to right
  defp convert([1, 1, 1, 0, 1, 1, 1]), do: 0
  defp convert([0, 0, 1, 0, 0, 1, 0]), do: 1
  defp convert([1, 0, 1, 1, 1, 0, 1]), do: 2
  defp convert([1, 0, 1, 1, 0, 1, 1]), do: 3
  defp convert([0, 1, 1, 1, 0, 1, 0]), do: 4
  defp convert([1, 1, 0, 1, 0, 1, 1]), do: 5
  defp convert([1, 1, 0, 1, 1, 1, 1]), do: 6
  defp convert([1, 0, 1, 0, 0, 1, 0]), do: 7
  defp convert([1, 1, 1, 1, 1, 1, 1]), do: 8
  defp convert([1, 1, 1, 1, 0, 1, 1]), do: 9
end
