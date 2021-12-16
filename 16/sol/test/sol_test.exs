defmodule SolTest do
  use ExUnit.Case
  doctest Sol

  alias Sol.Packet

  @literal "D2FE28"
  @operator_1 "38006F45291200"
  @operator_2 "EE00D40C823060"

  test "hex_to_binary/1" do
    assert Sol.hex_to_binary(@literal) == "110100101111111000101000"
  end

  test "Packet.parse/1" do
    assert %Packet{version: 6, type: :literal, payload: 2021} = Packet.parse!(@literal)

    assert %Packet{
             payload: [
               %Packet{payload: 10, type: :literal},
               %Packet{payload: 20, type: :literal}
             ],
             type: :operator,
             version: 1
           } = Packet.parse!(@operator_1)

    assert %Packet{
             payload: [
               %Packet{payload: 1, type: :literal},
               %Packet{payload: 2, type: :literal},
               %Packet{payload: 3, type: :literal}
             ],
             type: :operator,
             version: 7
           } = Packet.parse!(@operator_2)
  end

  test "Packet.version_total/1" do
    assert_version_total = fn packet_string, total ->
      assert total ==
               packet_string
               |> Packet.parse!()
               |> Packet.version_total()
    end

    scenarios = [
      {"8A004A801A8002F478", 16},
      {"620080001611562C8802118E34", 12},
      {"C0015000016115A2E0802F182340", 23},
      {"A0016C880162017C3686B18A3D4780", 31}
    ]

    for {packet, sum} <- scenarios do
      assert_version_total.(packet, sum)
    end
  end
end
