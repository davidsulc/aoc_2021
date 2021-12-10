defmodule Sol do
  @pairs [
    ~w/( )/,
    ~w/[ ]/,
    ~w/{ }/,
    ~w/< >/
  ]

  @matching @pairs |> Enum.map(fn [open, close] -> {close, open} end) |> Enum.into(%{})

  @opening Enum.map(@pairs, &hd/1)

  def part_1() do
    ~w(priv input.txt)
    |> Path.join()
    |> File.read!()
    |> solve_1()
  end

  def solve_1(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> Enum.map(&evaluate/1)
    |> Enum.flat_map(fn
      :ok -> []
      {:error, tok} -> [tok]
    end)
    |> Enum.map(&score/1)
    |> Enum.sum()
  end

  defp parse_line(line) do
    String.split(line, "", trim: true)
  end

  defp evaluate([h | t]), do: evaluate(t, [h])

  defp evaluate([], _), do: :ok

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
    case Map.get(@matching, closing) do
      ^opening -> true
      _ -> false
    end
  end

  [
    {")", 3},
    {"]", 57},
    {"}", 1197},
    {">", 25137}
  ]
  |> Enum.each(fn {tok, score} ->
    defp score(unquote(tok)), do: unquote(score)
  end)
end
