defmodule Sol do
  @file_path Path.join(~w(priv input.txt))

  def run_1(file \\ @file_path) do
    file
    |> prepare_stream()
    |> count(&increase?/2)
  end

  def run_2(file \\ @file_path) do
    file
    |> prepare_stream()
    |> to_sliding_window()
    |> Stream.map(&sum_window/1)
    |> count(&increase?/2)
  end

  defp prepare_stream(file) do
    file
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
  end

  defp to_sliding_window(stream, size \\ 3) do
    Stream.chunk_every(stream, size, 1, :discard)
  end

  defp sum_window(numbers) when length(numbers) == 3, do: Enum.sum(numbers)

  defp count(stream, condition) do
    {_, count} =
      Enum.reduce(stream, {nil, 0}, fn val, {prev, count} ->
        count =
          case condition.(prev, val) do
            true -> count + 1
            false -> count
          end

        {val, count}
      end)

    count
  end

  defp increase?(prev, curr)
       when is_integer(prev) and
              is_integer(curr) and
              prev < curr do
    true
  end

  defp increase?(_, _), do: false
end
