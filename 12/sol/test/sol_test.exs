defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  @small """
  start-A
  start-b
  A-c
  A-b
  b-d
  A-end
  b-end
  """

  @medium """
  dc-end
  HN-start
  start-kj
  dc-start
  dc-HN
  LN-dc
  HN-end
  kj-sa
  kj-HN
  kj-dc
  """

  @large """
  fs-end
  he-DX
  fs-he
  start-DX
  pj-DX
  end-zg
  zg-sl
  zg-pj
  pj-he
  RW-he
  fs-DX
  pj-RW
  zg-RW
  start-pj
  he-WI
  zg-he
  pj-fs
  start-RW
  """

  defp assert_results(solver, config) do
    for {input, expected_count} <- config do
      assert input |> Sol.parse_input() |> solver.() == expected_count
    end
  end

  test "solve_1/1" do
    assert_results(&Sol.solve_1/1, [
      {@small, 10},
      {@medium, 19},
      {@large, 226}
    ])
  end

  test "solve_2/1" do
    assert_results(&Sol.solve_2/1, [
      {@small, 36},
      {@medium, 103},
      {@large, 3509}
    ])
  end
end
