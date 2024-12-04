let read_file fname : string list =
  let ic = open_in fname in
  let rec read_lines acc =
    try
      let line = input_line ic in
      read_lines (line :: acc)
    with End_of_file ->
      close_in ic;
      List.rev acc
    in
        read_lines []
