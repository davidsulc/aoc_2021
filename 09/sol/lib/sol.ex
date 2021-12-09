defmodule Sol do
  defmodule Point do
    defstruct [:coordinates, :elevation, :minima, :basin]
  end

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
    low_points =
      input
      |> grid()
      |> scan_minimas()
      |> List.flatten()
      |> Enum.filter(fn {_measure, minima} -> minima end)
      |> Enum.map(&elem(&1, 0))

    Enum.sum(low_points) + length(low_points)
  end

  def part_2() do
    Path.join(~w(priv input.txt))
    |> File.read!()
    |> solve_part_2()
  end

  def solve_part_2(input) do
    basins_by_size =
      input
      |> grid()
      |> scan_minimas()
      |> convert_to_points()
      |> assign_basin()
      |> List.flatten()
      |> Enum.group_by(& &1.basin)
      |> Enum.into(%{})

    false = Map.has_key?(basins_by_size, nil)

    basins_by_size
    |> Map.delete(:none)
    |> Enum.sort_by(&(-length(elem(&1, 1))))
    |> Enum.take(3)
    |> Enum.map(&length(elem(&1, 1)))
    |> Enum.product()
  end

  defp convert_to_points(grid) do
    grid
    |> Enum.with_index()
    |> Enum.map(fn {line, row} ->
      line
      |> Enum.with_index()
      |> Enum.map(fn {{elevation, minima}, col} ->
        coords = {row, col}

        %Point{
          coordinates: coords,
          elevation: elevation,
          minima: minima,
          basin: if(minima, do: coords, else: nil)
        }
      end)
    end)
  end

  # we need to loop until all points have basins assigned, b/c basins
  # can "spread diagonally" (see case of point {3, 0} in example input)
  defp assign_basin(grid) when is_list(grid), do: assign_basin({nil, grid})

  defp assign_basin({grid, grid}), do: grid

  defp assign_basin({_, grid}) do
    previous_grid = grid

    current_grid =
      grid
      |> assign_basin_by_line()
      |> invert()
      |> assign_basin_by_line()
      |> invert()

    assign_basin({previous_grid, current_grid})
  end

  defp assign_basin_by_line([h | _] = grid) when is_list(h) do
    Enum.map(grid, fn line ->
      # we assign once going forward, and once going backwards
      # since we can't know which basin a point belongs to until
      # we've first iterated over a minima
      # We can just run assign_basin twice, as the accumulator
      # isn't reversed (the 2nd run will do the 2nd half of the
      # assignment work, as well as reverse the line)
      line
      |> assign_basin_by_line()
      |> assign_basin_by_line()
    end)
  end

  defp assign_basin_by_line(line) do
    assign_basin_by_line(line, {[], nil})
  end

  # don't reverse line: see assign_bassin/1
  defp assign_basin_by_line([], {acc, _bassin}), do: acc

  defp assign_basin_by_line([%Point{elevation: 9} = point | rest], {acc, _bassin}) do
    assign_basin_by_line(rest, {[%{point | basin: :none} | acc], nil})
  end

  defp assign_basin_by_line([%Point{minima: true} = point | rest], {acc, _basin}) do
    assign_basin_by_line(rest, {[point | acc], point.coordinates})
  end

  # basins "flow" from one row to another
  defp assign_basin_by_line([%Point{basin: basin} = point | rest], {acc, _basin})
       when not is_nil(basin) do
    assign_basin_by_line(rest, {[point | acc], point.basin})
  end

  defp assign_basin_by_line([%Point{minima: false} = point | rest], {acc, nil}) do
    assign_basin_by_line(rest, {[point | acc], nil})
  end

  defp assign_basin_by_line([%Point{minima: false} = point | rest], {acc, basin}) do
    assign_basin_by_line(rest, {[%{point | basin: basin} | acc], basin})
  end

  defp grid(input) do
    input
    |> parse_input()
    |> Enum.map(&to_depth_measure/1)
  end

  defp scan_minimas(grid) do
    # to find local minimas, we check once along the lines,
    # then across the columns
    grid
    |> evaluate_local_minima_by_line()
    |> invert()
    |> evaluate_local_minima_by_line()
    |> invert()
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
