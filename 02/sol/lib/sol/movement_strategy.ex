defmodule Sol.MovementStrategy do
  alias Sol.{Move, Position}

  @callback move(Position.t(), Move.t()) :: Position.t()
end
