defmodule Sol.MovementStrategies.Aim do
  alias Sol.{Move, Position}

  @behaviour Sol.MovementStrategy

  @impl true

  def move(%Position{} = pos, %Move{direction: :forward} = move),
    do: %{pos | horizontal: pos.horizontal + move.count, depth: pos.depth + pos.aim * move.count}

  def move(%Position{} = pos, %Move{direction: :up} = move),
    do: %{pos | aim: pos.aim - move.count}

  def move(%Position{} = pos, %Move{direction: :down} = move),
    do: %{pos | aim: pos.aim + move.count}
end
