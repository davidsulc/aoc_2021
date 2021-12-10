defmodule Sol do
  @pairs [
    ~w/( )/,
    ~w/[ ]/,
    ~w/{ }/,
    ~w/< >/
  ]

  @by_opening @pairs |> Enum.map(&List.to_tuple/1) |> Enum.into(%{})

  @by_closing @pairs |> Enum.map(fn [open, close] -> {close, open} end) |> Enum.into(%{})

  @opening Enum.map(@pairs, &hd/1)

  defp input() do
    ~w(priv input.txt)
    |> Path.join()
    |> File.read!()
  end

  def part_1() do
    solve_1(input())
  end

  def part_2() do
    solve_2(input())
  end

  def solve_1(input) do
    input
    |> parse_input()
    |> Enum.map(&evaluate/1)
    |> Enum.flat_map(fn
      {:ok, _} -> []
      {:error, tok} -> [tok]
    end)
    |> Enum.map(&score_1/1)
    |> Enum.sum()
  end

  def solve_2(input) do
    sorted_scores =
      input
      |> parse_input()
      |> Enum.filter(fn l ->
        case evaluate(l) do
          {:ok, _} -> true
          _ -> false
        end
      end)
      |> Enum.map(&complete/1)
      |> Enum.map(&score_2/1)
      |> Enum.sort()

    index = sorted_scores |> length() |> div(2)

    Enum.at(sorted_scores, index)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    String.split(line, "", trim: true)
  end

  defp evaluate([h | t]), do: evaluate(t, [h])

  defp evaluate([], acc), do: {:ok, acc}

  defp evaluate([open | rest], acc) when open in @opening do
    evaluate(rest, [open | acc])
  end

  defp evaluate(tokens, acc) do
    case matching_closing?(hd(tokens), hd(acc)) do
      true -> tokens |> tl() |> evaluate(tl(acc))
      false -> {:error, hd(tokens)}
    end
  end

  defp matching_closing?(closing, opening) do
    case Map.get(@by_closing, closing) do
      ^opening -> true
      _ -> false
    end
  end

  def complete(line) do
    {:ok, unmatched} = evaluate(line)

    Enum.map(unmatched, &Map.get(@by_opening, &1))
  end

  [
    {")", 3},
    {"]", 57},
    {"}", 1197},
    {">", 25137}
  ]
  |> Enum.each(fn {tok, score} ->
    defp score_1(unquote(tok)), do: unquote(score)
  end)

  defp score_2(line), do: score_2(line, 0)

  defp score_2([], acc), do: acc

  [
    {")", 1},
    {"]", 2},
    {"}", 3},
    {">", 4}
  ]
  |> Enum.each(fn {tok, score} ->
    defp score_2([unquote(tok) | rest], acc), do: score_2(rest, acc * 5 + unquote(score))
  end)
end
