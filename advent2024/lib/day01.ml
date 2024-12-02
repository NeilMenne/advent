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

let parse_line (line : string) : (int * int) =
  let parts = String.split_on_char ' ' line |> List.filter(fun s -> s <> "") in
    (int_of_string (List.nth parts 0), int_of_string (List.nth parts 1))

(* Part 1: Pair up the smallest number in the left list with the smallest number
   in the right list, then the second-smallest left number with the
   second-smallest right number, and so on. Within each pair, figure out how far
   apart the two numbers are; you'll need to add up all of those distances. *)
let part1 (fname : string) : int =
  let fs, ss = fname |> read_file |> List.map parse_line |> List.split in
  let sfs = List.sort compare fs in
  let sss = List.sort compare ss in
    List.fold_left(fun acc (f, s) -> abs(s - f) + acc) 0 (List.combine sfs sss)

let count_occurrences (x: int) (lst: int list) : int =
  List.fold_left (fun acc y -> if y = x then acc + 1 else acc) 0 lst

(* Part 2: Calculate a total similarity score by adding up each number in the
   left list after multiplying it by the number of times that number appears in
   the right list. *)
let part2 (fname : string) : int =
  let fs, ss = fname |> read_file |> List.map parse_line |> List.split in
  let sfs = List.sort compare fs in
  let sss = List.sort compare ss in
  List.fold_left(fun acc f ->
    let occ = count_occurrences f sss in
    (occ * f) + acc
  ) 0 sfs
