defmodule Sol.Part1 do
  alias Sol.{Input, Util}

  @path Path.join(~w(priv input.txt))

  def run(path \\ @path) do
    path
    |> Input.parse()
    |> power_consumption()
  end

  defp power_consumption(measures) do
    %{gamma: g, epsilon: e} =
      measures
      |> Stream.zip_with(& &1)
      |> compute_rates()

    g * e
  end

  defp compute_rates(parses_measures) do
    parses_measures
    |> Stream.map(&compute_single_rate/1)
    |> collect_rates()
    |> Enum.map(fn {k, v} -> {k, Util.bit_list_to_decimal(v)} end)
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

  defp collect_rates(rates) do
    %{gamma: g, epsilon: e} =
      Enum.reduce(rates, %{gamma: [], epsilon: []}, fn %{gamma: g, epsilon: e}, acc ->
        %{acc | gamma: [g | acc.gamma], epsilon: [e | acc.epsilon]}
      end)

    %{gamma: Enum.reverse(g), epsilon: Enum.reverse(e)}
  end
end
