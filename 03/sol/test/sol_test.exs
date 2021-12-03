defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  @path Path.join(~w(test example.txt))

  test "Part 1" do
    assert Sol.part_1(@path) == 198
  end
end
