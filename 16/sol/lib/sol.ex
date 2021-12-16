defmodule Sol do
  @packet_data """
  60556F980272DCE609BC01300042622C428BC200DC128C50FCC0159E9DB9AEA86003430BE5EFA8DB0AC401A4CA4E8A3400E6CFF7518F51A554100180956198529B6A700965634F96C0B99DCF4A13DF6D200DCE801A497FF5BE5FFD6B99DE2B11250034C00F5003900B1270024009D610031400E70020C0093002980652700298051310030C00F50028802B2200809C00F999EF39C79C8800849D398CE4027CCECBDA25A00D4040198D31920C8002170DA37C660009B26EFCA204FDF10E7A85E402304E0E60066A200F4638311C440198A11B635180233023A0094C6186630C44017E500345310FF0A65B0273982C929EEC0000264180390661FC403006E2EC1D86A600F43285504CC02A9D64931293779335983D300568035200042A29C55886200FC6A8B31CE647880323E0068E6E175E9B85D72525B743005646DA57C007CE6634C354CC698689BDBF1005F7231A0FE002F91067EF2E40167B17B503E666693FD9848803106252DFAD40E63D42020041648F24460400D8ECE007CBF26F92B0949B275C9402794338B329F88DC97D608028D9982BF802327D4A9FC10B803F33BD804E7B5DDAA4356014A646D1079E8467EF702A573FAF335EB74906CF5F2ACA00B43E8A460086002A3277BA74911C9531F613009A5CCE7D8248065000402B92D47F14B97C723B953C7B22392788A7CD62C1EC00D14CC23F1D94A3D100A1C200F42A8C51A00010A847176380002110EA31C713004A366006A0200C47483109C0010F8C10AE13C9CA9BDE59080325A0068A6B4CF333949EE635B495003273F76E000BCA47E2331A9DE5D698272F722200DDE801F098EDAC7131DB58E24F5C5D300627122456E58D4C01091C7A283E00ACD34CB20426500BA7F1EBDBBD209FAC75F579ACEB3E5D8FD2DD4E300565EBEDD32AD6008CCE3A492F98E15CC013C0086A5A12E7C46761DBB8CDDBD8BE656780
  """

  defmodule Packet do
    defstruct [:version, :type, :payload]

    def version_total(%__MODULE__{} = packet), do: version_total(packet, 0)

    defp version_total(%__MODULE__{type: :literal} = p, acc), do: p.version + acc

    defp version_total(%__MODULE__{type: :operator} = p, acc) do
      payload_sum =
        p.payload
        |> Enum.map(&version_total/1)
        |> Enum.sum()

      acc + p.version + payload_sum
    end

    def parse!(bits) do
      case parse(bits) do
        {:ok, packet} -> packet
        {:ok, packet, _} -> packet
      end
    end

    def parse(hex) when is_binary(hex) do
      hex
      |> Sol.hex_to_binary()
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
      |> parse()
    end

    def parse(bits) when is_list(bits), do: parse(bits, %__MODULE__{})

    defp parse(bits, %__MODULE__{} = packet) when length(bits) < 4, do: {:ok, packet}

    defp parse(remaining_bits, %__MODULE__{version: v, type: t, payload: p} = packet)
         when not is_nil(v) and not is_nil(t) and not is_nil(p),
         do: {:ok, packet, remaining_bits}

    defp parse(bits, %__MODULE__{version: nil} = packet) do
      {version, rest} = parse_bits(bits, 3)
      parse(rest, %{packet | version: version})
    end

    defp parse(bits, %__MODULE__{type: nil} = packet) do
      {type, rest} = parse_bits(bits, 3)

      type =
        case type do
          4 -> :literal
          _ -> :operator
        end

      parse(rest, %{packet | type: type})
    end

    defp parse(bits, %__MODULE__{type: :literal} = packet) do
      {literal, rest} = parse_literal_payload(bits)

      parse(rest, %{packet | payload: literal})
    end

    defp parse(bits, %__MODULE__{type: :operator} = packet) do
      {sub_packets, rest} = parse_sub_packets(bits)
      parse(rest, %{packet | payload: sub_packets})
    end

    defp parse_literal_payload(bits), do: parse_literal_payload(bits, [])

    defp parse_literal_payload([0 | _] = bits, acc) do
      {to_parse, rest} = Enum.split(bits, 5)

      group = tl(to_parse)

      int =
        [group | acc]
        |> Enum.reverse()
        |> List.flatten()
        |> Integer.undigits(2)

      {int, rest}
    end

    defp parse_literal_payload(bits, acc) do
      {to_parse, rest} = Enum.split(bits, 5)
      parse_literal_payload(rest, [tl(to_parse) | acc])
    end

    defp parse_sub_packets([length_type_id | rest]) do
      case length_type_id do
        0 ->
          {sub_packet_bit_count, rest} = parse_bits(rest, 15)
          {sub_packet_bits, rest} = Enum.split(rest, sub_packet_bit_count)

          sub_packets =
            sub_packet_bits
            |> Stream.unfold(fn
              [] ->
                nil

              bits ->
                case parse(bits) do
                  {:ok, packet, rest} -> {packet, rest}
                  {:ok, packet} -> {packet, []}
                end
            end)
            |> Enum.into([])

          {sub_packets, rest}

        1 ->
          {sub_packet_count, rest} = parse_bits(rest, 11)
          parse_sub_packets(rest, sub_packet_count, [])
      end
    end

    defp parse_sub_packets(rest, packet_count, packets) when packet_count == length(packets),
      do: {Enum.reverse(packets), rest}

    defp parse_sub_packets(bits, packet_count, packets) do
      {packet, rest} =
        case parse(bits) do
          {:ok, packet} -> {packet, []}
          {:ok, packet, rest} -> {packet, rest}
        end

      parse_sub_packets(rest, packet_count, [packet | packets])
    end

    defp parse_bits(bits, count) do
      {to_convert, rest} = Enum.split(bits, count)
      {Integer.undigits(to_convert, 2), rest}
    end
  end

  def part_1() do
    @packet_data
    |> String.trim()
    |> Packet.parse!()
    |> Packet.version_total()
  end

  def hex_to_binary(string), do: hex_to_binary(string, [])

  defp hex_to_binary("", acc), do: acc |> Enum.reverse() |> IO.iodata_to_binary()

  [
    {"0", "0000"},
    {"1", "0001"},
    {"2", "0010"},
    {"3", "0011"},
    {"4", "0100"},
    {"5", "0101"},
    {"6", "0110"},
    {"7", "0111"},
    {"8", "1000"},
    {"9", "1001"},
    {"A", "1010"},
    {"B", "1011"},
    {"C", "1100"},
    {"D", "1101"},
    {"E", "1110"},
    {"F", "1111"}
  ]
  |> Enum.each(fn {hex, binary} ->
    defp hex_to_binary(unquote(hex) <> rest, acc),
      do: hex_to_binary(rest, [unquote(binary) | acc])
  end)
end
