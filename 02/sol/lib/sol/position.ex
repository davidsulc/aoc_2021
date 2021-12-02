defmodule Sol.Position do
  alias Sol.Move

  @default_move_strategy Sol.MovementStrategies.Basic

  @type t :: %__MODULE__{}

  defstruct horizontal: 0, depth: 0, aim: 0

  def new() do
    %__MODULE__{}
  end

  def result(%__MODULE__{horizontal: h, depth: d}), do: h * d

  def apply(%__MODULE__{} = pos, %Move{} = move, opts \\ []) do
    opts
    |> get_movement_strategy()
    |> Kernel.apply(:move, [pos, move])
  end

  defp get_movement_strategy(opts),
    do: Keyword.get(opts, :movement_strategy, @default_move_strategy)
end
