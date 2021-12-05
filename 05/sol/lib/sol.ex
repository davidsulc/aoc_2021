defmodule Sol do
  @moduledoc """
  Documentation for `Sol`.
  """

  @path Path.join(~w(priv input.txt))

  def part_1(path \\ @path) do
    path
    |> File.stream!()
    |> Stream.map(&parse_line/1)
    |> Stream.filter(&line?/1)
    |> Stream.flat_map(&expand/1)
    |> Enum.group_by(& &1)
    |> Enum.reject(fn
      {_, [_]} -> true
      _ -> false
    end)
    |> length()
  end

  defp line?({{x, _}, {x, _}}), do: true
  defp line?({{_, y}, {_, y}}), do: true
  defp line?(_), do: false

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
end
