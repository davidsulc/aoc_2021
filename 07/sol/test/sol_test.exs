defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  @input "16,1,2,0,4,2,7,1,2,14"

  test "Part 1" do
    assert Sol.part_1(@input) == 37
  end
end
