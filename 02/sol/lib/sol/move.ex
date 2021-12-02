defmodule Sol.Move do
  @directions ~w(forward up down)

  defstruct [:direction, :count]

  @type t :: %__MODULE__{}

  def new(direction, count) do
    %__MODULE__{direction: direction, count: count}
  end

  def from_string(string) do
    string
    |> String.split()
    |> parse()
  end

  defp parse([direction, count]) do
    new(parse_direction(direction), parse_count(count))
  end

  defp parse_direction(direction) when direction in @directions do
    String.to_existing_atom(direction)
  end

  defp parse_count(count) do
    {count, ""} = Integer.parse(count)
    count
  end
end
