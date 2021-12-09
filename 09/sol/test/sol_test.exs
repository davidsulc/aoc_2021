defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  @test_input """
  2199943210
  3987894921
  9856789892
  8767896789
  9899965678
  """

  test "Part 1" do
    assert Sol.solve_part_1(@test_input) == 15
  end

  test "Part 2" do
    assert Sol.solve_part_2(@test_input) == 1134
  end
end
