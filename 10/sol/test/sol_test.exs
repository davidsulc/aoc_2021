defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  @input """
  [({(<(())[]>[[{[]{<()<>>
  [(()[<>])]({[<{<<[]>>(
  {([(<{}[<>[]}>{[]{[(<()>
  (((({<>}<{<{<>}{[]{[]{}
  [[<[([]))<([[{}[[()]]]
  [{[{({}]{}}([{[{{{}}([]
  {<[[]]>}<{[{[{[]{()[[[]
  [<(<(<(<{}))><([]([]()
  <{([([[(<>()){}]>(<<{{
  <{([{{}}[<[[[<>{}]]]>[]]
  """

  test "Part 1" do
    assert Sol.solve_1(@input) == 26397
  end

  test "Part 2" do
    assert Sol.solve_2(@input) == 288957
  end

  test "complete/1" do
    result =
      "[({(<(())[]>[[{[]{<()<>>"
      |> String.split("", trim: true)
      |> Sol.complete()
      |> Enum.join()

    assert result == "}}]])})]"
  end
end
