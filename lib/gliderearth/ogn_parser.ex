defmodule Gliderearth.OgnParser do
  import NimbleParsec

  eol =
    choice([
      string("\r\n"),
      string("\n")
    ])

  comment =
    string("# ")
    |> replace(:comment)
    |> unwrap_and_tag(:type)
    |> concat(
      utf8_string([not: ?\r, not: ?\n], min: 1)
      |> unwrap_and_tag(:comment)
    )
    |> ignore(eol)

  callsign =
    ascii_string([not: ?>], min: 1)
    |> unwrap_and_tag(:callsign)

  destination =
    ascii_string([not: ?,], min: 1)
    |> unwrap_and_tag(:destination)

  path =
    repeat(
      ascii_string([?A..?Z, ?a..?z, ?0..?9, ?,], min: 1)
      |> ignore(string(","))
    )
    |> tag(:path)

  receiver =
    ascii_string([not: ?:], min: 1)
    |> unwrap_and_tag(:receiver)

  time =
    integer(2)
    |> unwrap_and_tag(:hours)
    |> concat(
      integer(2)
      |> unwrap_and_tag(:minutes)
    )
    |> concat(
      integer(2)
      |> unwrap_and_tag(:seconds)
    )
    |> ignore(string("h"))
    |> tag(:time)

  ogn_data =
    ignore(string(" "))
    |> concat(
      ignore(string("id"))
      |> ascii_string([?0..?9, ?A..?F], max: 2)
    )
    |> tag(:ogn)

  position =
    string("/")
    |> replace(:position)
    |> unwrap_and_tag(:type)
    |> concat(time)
    |> concat(ascii_string([?0..?9, ?., ?N, ?S], max: 8) |> unwrap_and_tag(:latitude))
    |> concat(ascii_string([], max: 1) |> unwrap_and_tag(:symbol_table))
    |> concat(ascii_string([?0..?9, ?., ?W, ?E], max: 9) |> unwrap_and_tag(:longitude))
    |> concat(ascii_string([], max: 1) |> unwrap_and_tag(:symbol))
    |> concat(
      optional(
        integer(3)
        |> unwrap_and_tag(:course)
        |> ignore(string("/"))
        |> concat(integer(3) |> unwrap_and_tag(:ground_speed))
      )
    )
    |> concat(
      optional(
        ignore(string("/A="))
        |> ascii_string([?0..?9], min: 5, max: 6)
        |> unwrap_and_tag(:altitude)
      )
    )
    |> concat(
      optional(
        ignore(string(" !W"))
        |> ascii_string([?0..?9], max: 1)
        |> unwrap_and_tag(:latitude_enhancement)
        |> concat(
          ascii_string([?0..?9], max: 1)
          |> ignore(string("!"))
          |> unwrap_and_tag(:longitude_enhancement)
        )
      )
    )
    |> concat(optional(ogn_data))

  status =
    string(">")
    |> replace(:status)
    |> unwrap_and_tag(:type)
    |> concat(time)
    |> ignore(string(" "))
    |> concat(
      utf8_string([not: ?\r, not: ?\n], min: 1)
      |> unwrap_and_tag(:status)
    )
    |> ignore(eol)

  data =
    callsign
    |> ignore(string(">"))
    |> concat(destination)
    |> ignore(string(","))
    |> concat(path)
    |> concat(receiver)
    |> ignore(string(":"))
    |> choice([
      position,
      status
    ])

  defparsec(
    :parse,
    choice([
      comment,
      data
    ])
  )
end
