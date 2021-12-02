defmodule Sol.Position do
  alias Sol.Move

  defstruct horizontal: 0, depth: 0, aim: 0

  def new() do
    %__MODULE__{}
  end

  def result(%__MODULE__{horizontal: h, depth: d}), do: h * d

  def apply(%__MODULE__{} = pos, %Move{direction: direction} = move, use_aim? \\ false) do
    case direction do
      :forward -> advance(pos, move, use_aim?)
      :down -> dive(pos, move, use_aim?)
      :up -> surface(pos, move, use_aim?)
    end
  end

  defp advance(%__MODULE__{} = pos, %Move{count: count}, use_aim?) do
    pos = %{pos | horizontal: pos.horizontal + count}

    case use_aim? do
      false -> pos
      true -> %{pos | depth: pos.depth + pos.aim * count}
    end
  end

  defp dive(%__MODULE__{} = pos, %Move{count: count}, use_aim?) do
    case use_aim? do
      false -> %{pos | depth: pos.depth + count}
      true -> %{pos | aim: pos.aim + count}
    end
  end

  defp surface(%__MODULE__{} = pos, %Move{count: count}, use_aim?) do
    case use_aim? do
      false -> %{pos | depth: pos.depth - count}
      true -> %{pos | aim: pos.aim - count}
    end
  end
end
