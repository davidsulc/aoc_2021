defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  defp test_file(name), do: Path.join(["test", name])

  test "Part 1" do
    result =
      "example.txt"
      |> test_file()
      |> Sol.run_1()

    assert result == 7
  end

  test "Part 2" do
    result =
      "example.txt"
      |> test_file()
      |> Sol.run_2()

      assert result == 5
  end
end
