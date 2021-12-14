defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  @path Path.join(~w(test test_input.txt))

  test "Part 1" do
    assert Sol.part_1(@path) == 1588
  end
end
