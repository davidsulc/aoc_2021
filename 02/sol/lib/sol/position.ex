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
      up_or_down when up_or_down in ~w(up down)a -> apply_vertical_change(pos, move, use_aim?)
    end
  end

  defp advance(%__MODULE__{} = pos, %Move{count: count}, use_aim?) do
    pos = %{pos | horizontal: pos.horizontal + count}

    case use_aim? do
      false -> pos
      true -> %{pos | depth: pos.depth + pos.aim * count}
    end
  end

  defp apply_vertical_change(pos, move, use_aim?) do
    attr_to_change =
      case use_aim? do
        true -> :aim
        false -> :depth
      end

    Map.update!(pos, attr_to_change, position_updater(move))
  end

  defp position_updater(%Move{direction: :down, count: c}), do: &(&1 + c)
  defp position_updater(%Move{direction: :up, count: c}), do: &(&1 - c)
end
