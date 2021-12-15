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
      |> Stream.chunk_every(2, 1, :discard)
      |> Stream.map(&apply_to(rules, &1))
      |> Enum.into([])

    [
      hd(polymer_parts) |> hd()
      | Enum.flat_map(polymer_parts, fn [_x, y, z] -> [y, z] end)
    ]
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
      |> Enum.frequencies()
      |> Enum.min_max_by(fn {_k, v} -> v end)

    max - min
  end

  def part_1_b(path \\ @path), do: solve_for(path, 10)

  def part_2(path \\ @path), do: solve_for(path, 40)

  defp solve_for(path, passes) do
    rules = parse_rules(path)
    polymer = parse_polymer(path)

    pairs =
      polymer
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.frequencies()
      |> Enum.into(%{})

    letter_counts =
      polymer
      |> Enum.frequencies()
      |> Enum.into(%{})

    state = %{
      rules: rules,
      pairs: pairs,
      letter_counts: letter_counts
    }

    solve(state, passes)
  end

  defp solve(%{letter_counts: counts}, 0) do
    {{_, min}, {_, max}} = Enum.min_max_by(counts, fn {_, c} -> c end)
    max - min
  end

  defp solve(%{} = state, iterations) do
    state.pairs
    |> Enum.reduce(state, fn {pair, count}, acc ->
      case Map.get(state.rules, pair) do
        nil ->
          acc

        i ->
          [left, right] = pair

          updated_pairs =
            acc.pairs
            |> Map.update!(pair, &(&1 - count))
            |> Map.update([left, i], count, &(&1 + count))
            |> Map.update([i, right], count, &(&1 + count))

          %{
            acc
            | letter_counts: Map.update(acc.letter_counts, i, count, &(&1 + count)),
              pairs: updated_pairs
          }
      end
    end)
    |> solve(iterations - 1)
  end
end
