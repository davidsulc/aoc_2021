defmodule Sol do
  defmodule Grid do
    defstruct [:points, :max_coords]

    def from_dots(dot_coords) do
      %__MODULE__{
        points: MapSet.new(dot_coords),
        max_coords: compute_size(dot_coords)
      }
    end

    def parse(input) do
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line/1)
      |> from_dots()
    end

    defp parse_line(line) do
      [x, y] =
        line
        |> String.split(",", trim: true)
        |> Enum.map(&String.to_integer/1)

      {x, y}
    end

    defp compute_size(coords) do
      {x, _} = Enum.max_by(coords, &x/1)
      {_, y} = Enum.max_by(coords, &y/1)

      %{x: x, y: y}
    end

    def dot_count(%__MODULE__{points: points}), do: MapSet.size(points)

    def render(grid, fold_index \\ nil)

    def render(%__MODULE__{} = grid, nil), do: render(grid, fn _ -> false end)
    def render(%__MODULE__{} = grid, [{:x, index}]), do: render(grid, fn {x, _} -> x == index end)
    def render(%__MODULE__{} = grid, [{:y, index}]), do: render(grid, fn {_, y} -> y == index end)

    def render(%__MODULE__{} = grid, fold_point?) when is_function(fold_point?, 1) do
      %{points: points, max_coords: %{x: max_x, y: max_y}} = grid

      for y <- 0..max_y, x <- 0..(max_x + 1) do
        cond do
          x == max_x + 1 -> "\n"
          fold_point?.({x, y}) -> "+"
          MapSet.member?(points, {x, y}) -> "#"
          true -> "."
        end
      end
    end

    def fold(%__MODULE__{points: points} = grid, direction, fold_index) when is_atom(direction) do
      {unchanged, to_fold} = split(points, direction, fold_index)

      reader = direction |> reader()
      writer = direction |> writer()

      folded =
        to_fold
        |> Enum.map(fn coord ->
          writer.(coord, fold_index - (reader.(coord) - fold_index))
        end)
        |> MapSet.new()

      points = MapSet.union(folded, MapSet.new(unchanged))

      %{grid | points: points, max_coords: Map.put(grid.max_coords, direction, fold_index - 1)}
    end

    def fold_over(index, fold_index) when is_integer(index) and is_integer(fold_index) do
      IO.inspect({index, fold_index}, label: :fold_over)
      abs(index - fold_index) |> IO.inspect(label: :index)
    end

    defp split(coords, direction, index) do
      splitter = reader(direction)

      Enum.split_with(coords, fn coord ->
        # there should be no points of the fold line,
        # so we explicitly crash if that happens
        cond do
          splitter.(coord) > index -> false
          splitter.(coord) < index -> true
        end
      end)
    end

    defp reader(:x), do: &x/1
    defp reader(:y), do: &y/1

    defp writer(:x), do: &x(&1, &2)
    defp writer(:y), do: &y(&1, &2)

    defp x({x, _}), do: x
    defp y({_, y}), do: y

    defp x({_, y}, x), do: {x, y}
    defp y({x, _}, y), do: {x, y}
  end

  defp dot_coords() do
    ~w(priv dots.txt)
    |> Path.join()
    |> File.read!()
  end

  defp commands() do
    ~w(priv commands.txt)
    |> Path.join()
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_command/1)
  end

  defp parse_command(command) do
    [axis, index] =
      command
      |> String.trim_leading("fold along ")
      |> String.split("=", trim: true)

    {:"#{axis}", String.to_integer(index)}
  end

  def part_1() do
    dot_coords()
    |> Grid.parse()
    |> Grid.fold(:x, 655)
    |> Grid.dot_count()
  end

  def part_2() do
    commands()
    |> Enum.reduce(Grid.parse(dot_coords()), fn {direction, fold_index}, grid ->
      Grid.fold(grid, direction, fold_index)
    end)
    |> Grid.render()
    |> IO.puts()
  end
end
