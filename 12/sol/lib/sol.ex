defmodule Sol do
  defmodule Path do
    # For part 2, we stored "revisitable" which is the small cave which
    # the path is allowed to revisited. We achieve this by not reporting
    # the first visit to the cave when responding to visited/2.
    defstruct [:vertices, :visited, :revisitable]

    def new(revisitable \\ :none) do
      %__MODULE__{
        vertices: [:start],
        visited: MapSet.new([:start]),
        revisitable: revisitable
      }
    end

    def visited(%__MODULE__{visited: visited, revisitable: :none}), do: visited

    def visited(%__MODULE__{visited: visited, revisitable: revisitable}),
      do: MapSet.delete(visited, revisitable)

    def last_vertex(%__MODULE__{vertices: [last | _]}), do: last

    def done?(%__MODULE__{vertices: [:end | _]}), do: true
    def done?(%__MODULE__{}), do: false

    def extend(%__MODULE__{} = path, vertex) do
      revisitable =
        with ^vertex <- path.revisitable,
             true <- MapSet.member?(path.visited, vertex) do
          :none
        else
          _ -> path.revisitable
        end

      %{
        path
        | vertices: [vertex | path.vertices],
          visited: MapSet.put(path.visited, vertex),
          revisitable: revisitable
      }
    end
  end

  defmodule Graph do
    alias Sol.Path

    defstruct [:edges, :not_revisitable]

    def new(edges) do
      not_revisitable =
        edges
        |> vertices()
        |> Enum.filter(&not_revisitable?/1)
        |> MapSet.new()

      %__MODULE__{
        edges: edges,
        not_revisitable: not_revisitable
      }
    end

    def small_caves(%__MODULE__{} = graph) do
      graph
      |> vertices()
      |> Enum.filter(&not_revisitable?/1)
      |> Enum.reject(&(&1 in [:start, :end]))
    end

    defp not_revisitable?(name) do
      name = Atom.to_string(name)
      name == String.downcase(name)
    end

    def vertices(%__MODULE__{edges: edges}), do: vertices(edges)

    def vertices(edges) when is_list(edges),
      do: Enum.uniq(Keyword.keys(edges) ++ Keyword.values(edges))

    def neighbors(%__MODULE__{edges: edges}, from) do
      edges
      |> Keyword.get_values(from)
      |> MapSet.new()
    end

    def visitable(%__MODULE__{} = graph, %Path{} = path) do
      forbidden = MapSet.intersection(Path.visited(path), graph.not_revisitable)

      graph
      |> neighbors(Path.last_vertex(path))
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

  def part_2() do
    @input
    |> parse_input()
    |> solve_2()
  end

  def solve_1(graph) do
    graph
    |> Sol.find_paths()
    |> Enum.count()
  end

  def solve_2(graph) do
    seed_paths =
      graph
      |> Graph.small_caves()
      |> Enum.map(&Path.new/1)

    graph
    |> Sol.find_paths(seed_paths)
    |> Enum.map(&Map.get(&1, :vertices))
    |> Enum.uniq()
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

  def find_paths(%Graph{} = graph), do: find_paths(graph, [Path.new()])

  def find_paths(%Graph{} = graph, seed), do: find_paths(:cont, graph, seed)

  defp find_paths(:halt, _graph, paths), do: paths

  defp find_paths(:cont, graph, paths) do
    {continue?, paths} =
      case Enum.all?(paths, &Path.done?/1) do
        true -> {:halt, paths}
        false -> {:cont, Enum.flat_map(paths, &extend_path(&1, graph))}
      end

    find_paths(continue?, graph, paths)
  end

  def extend_path(%Path{} = path, graph) do
    case Path.done?(path) do
      true -> [path]
      false -> do_extend_path(path, graph)
    end
  end

  defp do_extend_path(%Path{} = path, graph) do
    visitable = Graph.visitable(graph, path)

    case MapSet.size(visitable) do
      # dead end => remove this path
      0 -> []
      _ -> Enum.map(visitable, &Path.extend(path, &1))
    end
  end
end
