defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  @input "16,1,2,0,4,2,7,1,2,14"

  test "Part 1" do
    assert Sol.part_1(@input) == 37
  end

  test "Part 2" do
    assert Sol.part_2(@input) == 168
  end

  test "total_fuel_to/2" do
    total =
      @input
      |> Sol.parse()
      |> Sol.total_fuel_to(5)

    assert total == 168
  end

  test "fuel_to/2" do
    assert Sol.fuel_to(16, 5) == 66
    assert Sol.fuel_to(1, 5) == 10
    assert Sol.fuel_to(0, 5) == 15
    assert Sol.fuel_to(2, 5) == 6
    assert Sol.fuel_to(4, 5) == 1
    assert Sol.fuel_to(14, 5) == 45
  end
end
