defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  alias Sol.{Grid, Path}

  @input """
  1163751742
  1381373672
  2136511328
  3694931569
  7463417111
  1319128137
  1359912421
  3125421639
  1293138521
  2311944581
  """

  test "solve_1/1" do
    assert Sol.solve_1(@input) == 40
  end
end
