defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  @moves Path.join(~w(test fixtures moves.txt))

  test "part 1" do
    assert Sol.part_1(@moves) == 150
  end
end
