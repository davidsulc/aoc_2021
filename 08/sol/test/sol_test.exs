defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  test "greets the world" do
    assert Sol.hello() == :world
  end
end
