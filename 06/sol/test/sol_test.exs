defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  @input "3,4,3,1,2"

  test "Part 1" do
    assert Sol.part_1(@input) == 5934
  end
end
