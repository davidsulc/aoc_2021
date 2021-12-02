defmodule Sol.Position do
  alias Sol.Move

  defstruct horizontal: 0, depth: 0

  def new() do
    %__MODULE__{}
  end

  def result(%__MODULE__{horizontal: h, depth: d}), do: h * d

  def apply(%__MODULE__{} = pos, %Move{direction: direction} = move) do
    case direction do
      :forward -> advance(pos, move)
      :down -> dive(pos, move)
      :up -> surface(pos, move)
    end
  end

  defp advance(%__MODULE__{} = pos, %Move{count: count}),
    do: %{pos | horizontal: pos.horizontal + count}

  defp dive(%__MODULE__{} = pos, %Move{count: count}),
    do: %{pos | depth: pos.depth + count}

  defp surface(%__MODULE__{} = pos, %Move{count: count}),
    do: %{pos | depth: pos.depth - count}
end
