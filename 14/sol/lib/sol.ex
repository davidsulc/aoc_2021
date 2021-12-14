defmodule Sol do
  @path Path.join(~w(priv input.txt))

  def parse_rules(path \\ @path) do
    path
    |> lines()
    |> tl()
    |> Enum.map(&parse_rule/1)
    |> Enum.into(%{})
  end

  def parse_polymer(path \\ @path) do
    path
    |> lines()
    |> hd()
    |> String.split("", trim: true)
  end

  defp lines(path) do
    path
    |> File.read!()
    |> String.split("\n", trim: true)
  end

  defp parse_rule(rule) do
    [pair, insertion] = String.split(rule, " -> ", trim: true)
    [left, right] = String.split(pair, "", trim: true)

    {[left, right], insertion}
  end

  def apply_to(rules, pair) do
    insertion = Map.fetch!(rules, pair)
    [left, right] = pair
    [left, insertion, right]
  end

  defp transform_once(rules, polymer) when is_list(polymer) do
    polymer_parts =
      polymer
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(&apply_to(rules, &1))

    [hd(polymer_parts) |> hd() | Enum.flat_map(polymer_parts, fn [_x, y, z] -> [y, z] end)]
  end

  defp transform(polymer, opts) do
    passes = Keyword.fetch!(opts, :passes)
    rules = Keyword.fetch!(opts, :rules)

    polymer
    |> Stream.unfold(fn p ->
      new_polymer = transform_once(rules, p)
      {new_polymer, new_polymer}
    end)
    |> Enum.at(passes)
  end

  def part_1(path \\ @path) do
    rules = parse_rules(path)

    {{_, min}, {_, max}} =
      path
      |> parse_polymer()
      |> transform(rules: rules, passes: 9)
      |> Enum.group_by(& &1)
      |> Enum.map(fn {k, v} -> {k, length(v)} end)
      |> Enum.min_max_by(fn {_k, v} -> v end)

    max - min
  end
end
