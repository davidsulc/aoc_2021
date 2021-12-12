defmodule Sol do
  defmodule Path do
    defstruct [:vertices, :visited]

    def new() do
      %__MODULE__{
        vertices: [:start],
        visited: MapSet.new([:start])
      }
    end

    def done?(%__MODULE__{vertices: [:end | _]}), do: true
    def done?(%__MODULE__{}), do: false

    def extend(%__MODULE__{} = path, vertex) do
      %{path | vertices: [vertex | path.vertices], visited: MapSet.put(path.visited, vertex)}
    end
  end

  defmodule Graph do
    defstruct [:edges, :not_revisitable]

    def new(edges) do
      not_revisitable =
        (Keyword.keys(edges) ++ Keyword.values(edges))
        |> Enum.uniq()
        |> Enum.filter(&not_revisitable?/1)
        |> MapSet.new()

      %__MODULE__{
        edges: edges,
        not_revisitable: not_revisitable
      }
    end

    defp not_revisitable?(name) do
      name = Atom.to_string(name)
      name == String.downcase(name)
    end

    def neighbors(%__MODULE__{edges: edges}, from) do
      edges
      |> Keyword.get_values(from)
      |> MapSet.new()
    end

    def visitable(%__MODULE__{} = graph, from, visited) do
      forbidden = MapSet.intersection(visited, graph.not_revisitable)

      graph
      |> neighbors(from)
      |> MapSet.difference(forbidden)
    end
  end

  @input """
  kc-qy
  qy-FN
  kc-ZP
  end-FN
  li-ZP
  yc-start
  end-qy
  yc-ZP
  wx-ZP
  qy-li
  yc-li
  yc-wx
  kc-FN
  FN-li
  li-wx
  kc-wx
  ZP-start
  li-kc
  qy-nv
  ZP-qy
  nv-xr
  wx-start
  end-nv
  kc-nv
  nv-XQ
  """

  def part_1() do
    @input
    |> parse_input()
    |> solve_1()
  end

  def solve_1(graph) do
    graph
    |> Sol.find_paths()
    |> Enum.count()
  end

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.flat_map(&parse_pair/1)
    |> Graph.new()
  end

  defp parse_pair(pair) do
    [left, right] =
      pair
      |> String.split("-", trim: true)
      |> Enum.map(&String.to_atom/1)

    [{left, right}, {right, left}]
  end

  def find_paths(%Graph{} = graph), do: find_paths(:cont, graph, [Path.new()])

  defp find_paths(:halt, _graph, paths), do: paths

  defp find_paths(:cont, graph, paths) do
    {continue?, paths} =
      case Enum.all?(paths, &Path.done?/1) do
        true -> {:halt, paths}
        false -> {:cont, Enum.flat_map(paths, &extend_path(&1, graph))}
      end

    find_paths(continue?, graph, paths)
  end

  def extend_path(%Path{vertices: [:end | _]} = path, _graph), do: [path]

  def extend_path(%Path{vertices: [vertex | _]} = path, graph) do
    visitable = Graph.visitable(graph, vertex, path.visited)

    case MapSet.size(visitable) do
      # dead end => remove this path
      0 -> []
      _ -> Enum.map(visitable, &Path.extend(path, &1))
    end
  end
end
