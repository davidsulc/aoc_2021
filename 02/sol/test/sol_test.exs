defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  @moves Path.join(~w(test fixtures moves.txt))

  test "part 1" do
    assert Sol.part_1(@moves) == 150
  end

  test "part 2" do
    assert Sol.part_2(@moves) == 900
  end
end
