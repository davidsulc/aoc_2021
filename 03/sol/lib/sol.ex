defmodule Sol do
  @path Path.join(~w(priv input.txt))

  def part_1(path \\ @path) do
    path
    |> parse()
    |> power_consumption()
  end

  defp parse(path) do
    path
    |> File.stream!()
    |> Stream.map(&parse_measures/1)
  end

  defp power_consumption(measures) do
    %{gamma: g, epsilon: e} =
      measures
      |> Stream.zip_with(& &1)
      |> compute_rates()

    g * e
  end

  defp parse_measures(string) when is_binary(string) do
    string
    |> String.trim()
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp compute_rates(parses_measures) do
    parses_measures
    |> Stream.map(&compute_single_rate/1)
    |> collect_rates()
    |> Enum.map(fn {k, v} -> {k, bit_list_to_decimal(v)} end)
    |> Enum.into(%{})
  end

  defp compute_single_rate(bits) when is_list(bits) do
    {zeroes, ones} = Enum.split_with(bits, &(&1 == 0))

    {gamma, epsilon} =
      case length(zeroes) > length(ones) do
        true -> {0, 1}
        false -> {1, 0}
      end

    %{gamma: gamma, epsilon: epsilon}
  end

  defp bit_list_to_decimal(bits) do
    {decimal, ""} =
      bits
      |> Enum.join("")
      |> Integer.parse(2)

    decimal
  end

  defp collect_rates(rates) do
    %{gamma: g, epsilon: e} =
      Enum.reduce(rates, %{gamma: [], epsilon: []}, fn %{gamma: g, epsilon: e}, acc ->
        %{acc | gamma: [g | acc.gamma], epsilon: [e | acc.epsilon]}
      end)

    %{gamma: Enum.reverse(g), epsilon: Enum.reverse(e)}
  end
end