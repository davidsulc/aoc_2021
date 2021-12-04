defmodule Sol.Board do
  @separator " "

  defmodule CellContents do
    defstruct [:number, marked: false]

    def new(number), do: %__MODULE__{number: number}

    def mark(%__MODULE__{} = contents), do: %{contents | marked: true}

    def marked?(%__MODULE__{marked: marked}), do: marked
  end

  defstruct [:size, :cells, :index, winner: false]

  def parse(string) when is_binary(string) do
    grid = parse_grid(string)
    row_count = length(grid)
    # we assume boards aren't malformed (i.e. all colls will be of same size)
    col_count = grid |> hd() |> length()

    number_coords =
      grid
      |> with_coordinates()
      |> List.flatten()

    cells =
      number_coords
      |> Enum.map(fn {number, coords} ->
        {coords, CellContents.new(number)}
      end)
      |> Enum.into(%{})

    %__MODULE__{
      cells: cells,
      size: %{rows: row_count, cols: col_count},
      index:
        Enum.reduce(number_coords, %{}, fn {number, coords}, acc ->
          Map.update(acc, number, [coords], &[coords | &1])
        end)
    }
  end

  def mark(%__MODULE__{winner: true} = board, _number), do: board

  def mark(%__MODULE__{} = board, number) when is_integer(number) do
    case Map.get(board.index, number) do
      nil ->
        board

      coords ->
        Enum.reduce(coords, board, fn {row, col} = coord, acc ->
          board = mark_cell(acc, coord)
          %{board | winner: row_complete?(board, row) or col_complete?(board, col)}
        end)
    end
  end

  def unmarked_sum(%__MODULE__{} = board) do
    board.cells
    |> Map.values()
    |> Enum.reject(&CellContents.marked?/1)
    |> Enum.map(& &1.number)
    |> Enum.sum()
  end

  defp row_complete?(%__MODULE__{} = board, row_index) do
    board
    |> row!(row_index)
    |> Enum.all?(&CellContents.marked?/1)
  end

  defp col_complete?(%__MODULE__{} = board, col_index) do
    board
    |> col!(col_index)
    |> Enum.all?(&CellContents.marked?/1)
  end

  defp mark_cell(%__MODULE__{} = board, coord) do
    cell_contents = cell!(board, coord)
    %{board | cells: Map.replace!(board.cells, coord, CellContents.mark(cell_contents))}
  end

  defp cell!(%__MODULE__{cells: cells}, coord) do
    Map.fetch!(cells, coord)
  end

  defp row!(%__MODULE__{} = board, row_index) do
    0..(board.size.cols - 1)
    |> Enum.map(&cell!(board, {row_index, &1}))
  end

  defp col!(%__MODULE__{} = board, col_index) do
    0..(board.size.rows - 1)
    |> Enum.map(&cell!(board, {&1, col_index}))
  end

  def parse_grid(string) when is_binary(string) do
    string
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  def with_coordinates(grid) do
    grid
    |> Enum.with_index()
    |> Enum.map(&line_to_row/1)
  end

  defp parse_line(line) do
    line
    |> String.split(@separator, trim: true)
    |> Enum.map(&parse_cell/1)
  end

  defp parse_cell(number_string), do: String.to_integer(number_string)

  defp line_to_row({line, row_index}) do
    line
    |> Enum.with_index()
    |> Enum.map(fn {number, col_index} ->
      {number, {row_index, col_index}}
    end)
  end
end
