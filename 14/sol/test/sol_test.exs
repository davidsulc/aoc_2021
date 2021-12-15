defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  @path Path.join(~w(test test_input.txt))

  test "Part 1" do
    assert Sol.part_1(@path) == 1588
  end

  test "Part 1 b" do
    assert Sol.part_1_b(@path) == 1588
  end

  test "Part 2" do
    assert Sol.part_2(@path) == 2_188_189_693_529
  end
end
