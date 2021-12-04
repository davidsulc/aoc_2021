defmodule Sol.Part2 do
  alias Sol.{Input, Util}

  @path Path.join(~w(priv input.txt))

  def run(path \\ @path) do
    input = Input.parse(path) |> Enum.into([])

    measures =
      for measure_name <- [:oxygen, :co2], into: %{} do
        {measure_name, get_measure(measure_name, input)}
      end

    measures.oxygen * measures.co2
  end

  defp get_measure(measure_name, input) do
    criteria = measure_criteria(measure_name)

    input
    |> filter(criteria)
    |> Util.bit_list_to_decimal()
  end

  defp measure_criteria(:oxygen), do: :most_common
  defp measure_criteria(:co2), do: :least_common

  defp filter(list_of_number_bits, criteria), do: filter(list_of_number_bits, criteria, 0)

  defp filter([number_bits], _criteria, _bit_index), do: number_bits

  defp filter(list_of_number_bits, criteria, bit_index) do
    list_of_number_bits
    |> Enum.split_with(&(Enum.at(&1, bit_index) == 0))
    |> select(criteria)
    |> filter(criteria, bit_index + 1)
  end

  defp select({left, right}, :least_common) when length(left) == length(right), do: left
  defp select({left, right}, :least_common) when length(left) < length(right), do: left
  defp select({_left, right}, :least_common), do: right
  defp select({left, right}, :most_common) when length(left) == length(right), do: right
  defp select({left, right}, :most_common) when length(left) < length(right), do: right
  defp select({left, _right}, :most_common), do: left
end
