defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  @input "3,4,3,1,2"

  test "Part 1" do
    assert Sol.part_1(@input) == 5934
  end

  test "Part 2" do
    assert Sol.part_2(@input) == 26_984_457_539
  end
end
