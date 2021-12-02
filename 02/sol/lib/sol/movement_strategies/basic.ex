defmodule Sol.MovementStrategies.Basic do
  alias Sol.{Move, Position}

  @behaviour Sol.MovementStrategy

  @impl true

  def move(%Position{} = pos, %Move{direction: :forward} = move),
    do: %{pos | horizontal: pos.horizontal + move.count}

  def move(%Position{} = pos, %Move{direction: :up} = move),
    do: %{pos | depth: pos.depth - move.count}

  def move(%Position{} = pos, %Move{direction: :down} = move),
    do: %{pos | depth: pos.depth + move.count}
end
