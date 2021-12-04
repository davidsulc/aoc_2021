defmodule Sol.Util do
  def bit_list_to_decimal(bits) do
    {decimal, ""} =
      bits
      |> Enum.join("")
      |> Integer.parse(2)

    decimal
  end
end
