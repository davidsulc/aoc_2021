defmodule Sol.Input do
  def parse(path) do
    path
    |> File.stream!()
    |> Stream.map(&parse_measures/1)
  end

  defp parse_measures(string) when is_binary(string) do
    string
    |> String.trim()
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
