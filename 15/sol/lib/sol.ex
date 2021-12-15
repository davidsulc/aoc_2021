defmodule Sol do
  defmodule Grid do
    @behaviour Access

    defstruct [:points, :max_coords]

    defguard is_coord(coord) when is_tuple(coord) and tuple_size(coord) == 2

    @impl Access
    defdelegate fetch(term, key), to: Map

    @impl Access
    defdelegate get_and_update(term, key, fun), to: Map

    @impl Access
    defdelegate pop(term, key), to: Map

    def parse(string) do
      lines = String.split(string, "\n", trim: true)

      points =
        lines
        |> Enum.with_index()
        |> Enum.flat_map(fn {line, y} ->
          line
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.map(fn {n, x} -> {{x, y}, %{risk: String.to_integer(n), visited?: false}} end)
        end)
        |> Enum.into(%{})

      x_point_count = lines |> hd() |> String.length()
      y_point_count = length(lines)

      %__MODULE__{
        points: points,
        max_coords: %{x: x_point_count - 1, y: y_point_count - 1}
      }
    end

    def render(%__MODULE__{} = grid),
      do: render(grid, MapSet.new())

    def render(%__MODULE__{max_coords: %{x: max_x}} = grid, visited) do
      grid
      |> coords()
      |> Enum.map(fn coord ->
        pretty_risk = &(grid |> risk(&1) |> inspect())

        rendered_cell =
          case MapSet.member?(visited, coord) do
            true -> ["(", pretty_risk.(coord), ")"]
            false -> [" ", pretty_risk.(coord), " "]
          end

        case coord do
          {x, _} when x == max_x -> [rendered_cell, "\n"]
          _ -> rendered_cell
        end
      end)
    end

    def coords(%__MODULE__{max_coords: %{x: max_x, y: max_y}}) do
      Stream.unfold({0, 0}, fn
        :done -> nil
        {^max_x, ^max_y} = coord -> {coord, :done}
        {^max_x, y} = coord -> {coord, {0, y + 1}}
        {x, y} = coord -> {coord, {x + 1, y}}
      end)
    end

    def risk(%__MODULE__{} = grid, coord) when is_coord(coord),
      do: get_in(grid, [:points, coord, :risk])
  end

  defmodule Path do
    def find_shortest(%Grid{} = grid) do
      start_coord = {0, 0}
      %{max_coords: %{x: x, y: y}} = grid
      end_coord = {x, y}

      initial_state =
        grid
        |> Grid.coords()
        |> Enum.map(fn coord ->
          {coord,
           %{
             parent: nil,
             risk: Sol.Grid.risk(grid, coord),
             total_risk: :infinity,
             visited?: false
           }}
        end)
        |> Enum.into(%{})
        |> Map.put(start_coord, %{parent: nil, risk: 1, total_risk: 0, visited?: false})

      find_shortest(:cont, initial_state, end_coord)
    end

    # https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm#Pseudocode
    defp find_shortest(:halt, %{} = state, end_coord) do
      state
      |> Map.get(end_coord)
      |> Map.get(:total_risk)
    end

    defp find_shortest(:cont, %{} = state, end_coord) do
      {continue?, state} =
        case Enum.min_by(state, fn
               {_, %{visited?: true}} -> :infinity
               {_, %{total_risk: r}} -> r
             end) do
          {^end_coord, _} ->
            {:halt, state}

          {coord, coord_info} ->
            state = Map.update!(state, coord, fn map -> %{map | visited?: true} end)

            state =
              coord
              |> neighbors(state)
              |> Enum.reduce(state, fn neighbor, acc ->
                step_risk = get_in(acc, [neighbor, :risk])
                alt = coord_info.total_risk + step_risk

                case alt < state[neighbor].total_risk do
                  true ->
                    Map.put(acc, neighbor, %{
                      state[neighbor]
                      | parent: coord,
                        risk: step_risk,
                        total_risk: alt
                    })

                  false ->
                    acc
                end
              end)

            {:cont, state}
        end

      find_shortest(continue?, state, end_coord)
    end

    defp neighbors({x_coord, y_coord}, coord_map) do
      visited? = fn coord_tuple ->
        get_in(coord_map, [coord_tuple, :visited?])
      end

      for x <- (x_coord - 1)..(x_coord + 1),
          y <- (y_coord - 1)..(y_coord + 1),
          x == x_coord or y == y_coord,
          not (x == x_coord and y == y_coord),
          x >= 0,
          y >= 0 do
        {x, y}
      end
      |> Enum.filter(&Map.has_key?(coord_map, &1))
      |> Enum.reject(visited?)
    end
  end

  def part_1() do
    ~w(priv input.txt)
    |> Elixir.Path.join()
    |> File.read!()
    |> solve_1()
  end

  def solve_1(input) do
    input
    |> Grid.parse()
    |> Path.find_shortest()
  end
end
