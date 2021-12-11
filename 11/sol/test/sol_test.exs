defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  @small_input """
  11111
  19991
  19191
  19991
  11111
  """

  @input """
    5483143223
    2745854711
    5264556173
    6141336146
    6357385478
    4167524645
    2176841721
    6882881134
    4846848554
    5283751526
    """

  alias Sol.Grid

  defp assert_grid(expected, actual) do
    assert String.trim_trailing(expected, "\n") == Grid.to_string(actual)
  end

  test "step/1" do
    {grid, _} =
      @small_input
      |> Grid.from_string()
      |> Sol.step()

    assert_grid("""
    34543
    40004
    50005
    40004
    34543
    """, grid)

    {grid, _} = Sol.step(grid)

    assert_grid("""
    45654
    51115
    61116
    51115
    45654
    """, grid)
  end

  test "step/2" do
    grid = Grid.from_string(@small_input)

    {grid, flash_count} = Sol.step(grid, 2)

    assert_grid("""
    45654
    51115
    61116
    51115
    45654
    """, grid)

    assert flash_count == 9

    {grid, flash_count} =
      @input
      |> Grid.from_string()
      |> Sol.step(10)

      assert_grid("""
        0481112976
        0031112009
        0041112504
        0081111406
        0099111306
        0093511233
        0442361130
        5532252350
        0532250600
        0032240000
        """, grid)

      assert flash_count == 204

    {grid, flash_count} =
      @input
      |> Grid.from_string()
      |> Sol.step(100)

      assert_grid("""
        0397666866
        0749766918
        0053976933
        0004297822
        0004229892
        0053222877
        0532222966
        9322228966
        7922286866
        6789998766
        """, grid)

      assert flash_count == 1656
  end

  test "find_simultaneous_flash/1" do
    step_count =
      @input
      |> Grid.from_string()
      |> Sol.find_simultaneous_flash()

    assert step_count == 195
  end
end
