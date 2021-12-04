defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  @path Path.join(~w(test example.txt))

  test "Part 1" do
    assert Sol.part_1(@path) == 4512
  end

  test "Part 2" do
    assert Sol.part_2(@path) == 1924
  end
end
