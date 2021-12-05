defmodule Sol do
  @moduledoc """
  Documentation for `Sol`.
  """

  @path Path.join(~w(priv input.txt))

  defp input(path) do
    path
    |> File.stream!()
    |> Stream.map(&parse_line/1)
  end

  def part_1(path \\ @path) do
    path
    |> input()
    |> Stream.filter(&straight_line?/1)
    |> count_overlaps()
  end

  def part_2(path \\ @path) do
    path
    |> input()
    |> count_overlaps()
  end

  defp count_overlaps(lines) do
    lines
    |> Stream.flat_map(&expand/1)
    |> Enum.group_by(& &1)
    |> Enum.reject(fn
      {_, [_]} -> true
      _ -> false
    end)
    |> length()
  end

  defp straight_line?({{x, _}, {x, _}}), do: true
  defp straight_line?({{_, y}, {_, y}}), do: true
  defp straight_line?(_), do: false

  defp parse_line(line) do
    [from, to] =
      line
      |> String.trim()
      |> String.split(" -> ")
      |> Enum.map(&parse_coord/1)

    {from, to}
  end

  defp parse_coord(coord) do
    [x, y] =
      coord
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    {x, y}
  end

  defp expand({{x, y_from}, {x, y_to}}) do
    for y <- y_from..y_to do
      {x, y}
    end
  end

  defp expand({{x_from, y}, {x_to, y}}) do
    for x <- x_from..x_to do
      {x, y}
    end
  end

  defp expand(diagonal), do: expand_diagonal(diagonal, [])

  defp expand_diagonal({{x, y}, {x, y}}, acc), do: [{x, y} | acc]

  defp expand_diagonal({{x_l, y_l} = from, {x_r, y_r} = to}, acc) do
    x =
      case x_l < x_r do
        true -> x_l + 1
        _ -> x_l - 1
      end

    y =
      case y_l < y_r do
        true -> y_l + 1
        _ -> y_l - 1
      end

    expand_diagonal({{x, y}, to}, [from | acc])
  end
end
