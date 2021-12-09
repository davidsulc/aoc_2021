defmodule Sol do
  def parse_input(string) do
    string
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def parse_line(line) do
    line
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def part_1() do
    Path.join(~w(priv input.txt))
    |> File.read!()
    |> solve_part_1()
  end

  def solve_part_1(input) do
    # to find local minimas, we check once along the lines,
    # then across the columns
    horizontal_scan =
      input
      |> parse_input()
      |> Enum.map(&to_depth_measure/1)
      |> evaluate_local_minima_by_line()

    complete_scan =
      horizontal_scan
      |> invert()
      |> evaluate_local_minima_by_line()

    low_points =
      complete_scan
      |> invert()
      |> List.flatten()
      |> Enum.filter(fn {_measure, minima} -> minima end)
      |> Enum.map(&elem(&1, 0))

    Enum.sum(low_points) + length(low_points)
  end

  # flips grid (lines become cols)
  defp invert(lines) do
    lines
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  defp to_depth_measure(l) when is_list(l) do
    Enum.map(l, &to_depth_measure/1)
  end

  defp to_depth_measure(m) when is_integer(m) do
    # boolean indicates "is potential local minima"
    {m, true}
  end

  def evaluate_local_minima_by_line([h | _] = lines) when is_list(h) do
    Enum.map(lines, &evaluate_local_minima_in_line/1)
  end

  def evaluate_local_minima_in_line([h | _] = line) do
    evaluate_local_minima_in_line(line, [evaluate_minima(h, Enum.take(line, 2))])
  end

  defp evaluate_local_minima_in_line([_], acc), do: Enum.reverse(acc)

  defp evaluate_local_minima_in_line([_, measure | _] = line, acc) do
    evaluate_local_minima_in_line(tl(line), [evaluate_minima(measure, Enum.take(line, 3)) | acc])
  end

  # start of line => single neighbor
  defp evaluate_minima(measure, [measure, other]) do
    case measure |> smaller_than?(other) do
      false -> not_minima(measure)
      true -> measure
    end
  end

  # end of line => single neighbor
  defp evaluate_minima(measure, [other, measure]) do
    case measure |> smaller_than?(other) do
      false -> not_minima(measure)
      true -> measure
    end
  end

  defp evaluate_minima(measure, [left, measure, right]) do
    case measure |> smaller_than?(left) and measure |> smaller_than?(right) do
      false -> not_minima(measure)
      true -> measure
    end
  end

  defp smaller_than?({left, _}, {right, _}), do: left < right

  defp not_minima({x, _}), do: {x, false}
end
