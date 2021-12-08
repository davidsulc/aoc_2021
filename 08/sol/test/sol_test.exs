defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  @input "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf"

  test "Part 2" do
    sum =
    Path.join(~w(test example.txt))
    |> Sol.part_2()

    assert sum == 61229
  end

  test "determine_number/1" do
    total =
      @input
      |> Sol.parse_line()
      |> Sol.determine_number()

    assert total == 5353
  end

  @config %{
    0 => :d,
    1 => :e,
    2 => :a,
    3 => :f,
    4 => :g,
    5 => :b,
    6 => :c
  }

  test "resolve_config/2" do
    assert @config =
             Sol.resolve_config("acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab")
  end

  test "display/2" do
    assert Sol.display(~w(a b)a, @config) == 1
    assert Sol.display(~w(c d f e b)a, @config) == 5
    assert Sol.display(~w(f c a d b)a, @config) == 3
  end
end
