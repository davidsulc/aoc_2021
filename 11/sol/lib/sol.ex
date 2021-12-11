defmodule Sol do
  defmodule Grid do
    defstruct [:points, :size]

    def from_string(string) when is_binary(string) do
      points =
        string
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          line
          |> String.split("", trim: true)
          |> Enum.map(&String.to_integer/1)
        end)

      height = length(points)
      width = points |> hd() |> length()

      %__MODULE__{points: points, size: %{height: height, width: width}}
    end

    def map(%__MODULE__{} = grid, mapper) when is_function(mapper, 1) do
      map(grid, fn point, _coord -> mapper.(point) end)
    end

    def map(%__MODULE__{points: points} = grid, mapper) when is_function(mapper, 2) do
      updated_points =
        points
        |> Enum.with_index()
        |> Enum.map(fn {line, row_index} ->
          line
          |> Enum.with_index()
          |> Enum.map(fn {point, col_index} ->
            mapper.(point, {row_index, col_index})
          end)
        end)

      %{grid | points: updated_points}
    end

    def filter(%__MODULE__{points: grid}, filter) when is_function(filter, 2) do
      grid
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, row_index} ->
        line
        |> Enum.with_index()
        |> Enum.reduce([], fn {point, col_index}, acc ->
          coord = {row_index, col_index}

          case filter.(point, coord) do
            true -> [{point, coord} | acc]
            false -> acc
          end
        end)
      end)
    end

    def to_string(%__MODULE__{} = grid), do: String.Chars.to_string(grid)
  end

  defimpl String.Chars, for: Grid do
    def to_string(%{points: points}) do
      points
      |> Enum.map(fn line -> Enum.map(line, &Integer.to_string/1) end)
      |> Enum.intersperse("\n")
      |> IO.iodata_to_binary()
    end
  end

  @input """
  4585612331
  5863566433
  6714418611
  1746467322
  6161775644
  6581631662
  1247161817
  8312615113
  6751466142
  1161847732
  """

  def part_1() do
    {_, count} =
      @input
      |> Grid.from_string()
      |> step(100)

    count
  end

  def part_1_unfold() do
    @input
    |> Grid.from_string()
    |> stream_flash_counts()
    |> Stream.take(100)
    |> Enum.sum()
  end

  def part_2() do
    @input
    |> Grid.from_string()
    |> find_simultaneous_flash()
  end

  def part_2_unfold() do
    grid =
      @input
      |> Grid.from_string()

    total_count = grid.size.width * grid.size.height

    grid
    |> stream_flash_counts()
    |> Stream.take_while(& &1 != total_count)
    |> Enum.count()
    |> then(& &1 + 1)
  end

  defp stream_flash_counts(grid) do
    Stream.unfold(grid, fn g ->
      {grid, flash_coords} = step(g)
      {MapSet.size(flash_coords), grid}
    end)
  end

  def find_simultaneous_flash(%Grid{} = grid) do
    find_simultaneous_flash(grid, {0, nil})
  end

  defp find_simultaneous_flash(%Grid{size: %{width: w, height: h}}, {step_count, flash_count})
      when is_integer(flash_count) and flash_count == w * h,
    do: step_count

  defp find_simultaneous_flash(grid, {step_count, _flash_count}) do
    {grid, flash_coords} = step(grid)
    find_simultaneous_flash(grid, {step_count + 1, MapSet.size(flash_coords)})
  end

  def step(%Grid{} = grid, steps) do
    Enum.reduce(1..steps, {grid, 0}, fn _, {grid, flash_count} ->
      {grid, flash_coords} = step(grid)
      {grid, flash_count + MapSet.size(flash_coords)}
    end)
  end

  def step(%Grid{} = grid) do
    step(:cont, Grid.map(grid, & &1 + 1), MapSet.new())
  end

  defp step(:halt, grid, acc_flashes), do: {grid, acc_flashes}

  defp step(:cont, grid, acc_flashes) do
    {grid, new_flashes} = trigger_flashes(grid)
    all_flashes = MapSet.union(acc_flashes, new_flashes)

    {continue?, grid} =
      case MapSet.size(new_flashes) do
        0 -> {:halt, grid}
        _ ->
          # we need to increment the cells in the blast radius
          # of cells having flashed, unless the cell itself has flashed
          grid = Grid.map(grid, fn level, coord ->
            case MapSet.member?(all_flashes, coord) do
              true -> level
              false -> level + count_neighbors(new_flashes, coord)
            end
          end)

          {:cont, grid}
      end

    step(continue?, grid, all_flashes)
  end

  defp count_neighbors(coords, {_x, _y} = cell) do
    coords
    |> MapSet.intersection(neighbors(cell))
    |> MapSet.size()
  end

  defp neighbors({x, y}) do
    neighbors =
      for coord_x <- (x - 1)..(x + 1),
          coord_x >= 0,
          coord_x <= 10,
          coord_y <- (y - 1)..(y + 1),
          coord_y >= 0,
          coord_y <= 10 do
        {coord_x, coord_y}
      end

    MapSet.new(neighbors)
  end

  # returns {grid, cells} where
  # * grid has been updated to set the levels of cells having
  #     flashed back down to 0
  # * cells is a map set of coordinates for the cells that flashed
  defp trigger_flashes(%Grid{} = grid) do
    flash_triggered? = fn level, _coord -> level > 9 end

    flash_coords =
      grid
      |> Grid.filter(flash_triggered?)
      |> Enum.map(&elem(&1, 1))
      |> MapSet.new()

    grid =
      Grid.map(grid, fn level, coord ->
        case flash_triggered?.(level, coord) do
          true -> 0
          false -> level
        end
      end)

    {grid, flash_coords}
  end
end
