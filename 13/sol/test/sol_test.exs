defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  alias Sol.Grid

  @points """
  6,10
  0,14
  9,10
  0,3
  10,4
  4,11
  6,0
  6,12
  4,1
  0,13
  10,12
  3,4
  3,0
  8,4
  1,10
  2,14
  8,10
  9,0
  """

  test "fold/3" do
    assert 17 ==
             @points
             |> Grid.parse()
             |> Grid.fold(:y, 7)
             |> Grid.dot_count()
  end
end
