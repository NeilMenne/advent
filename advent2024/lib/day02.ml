let parse_input s =
  s
  |> String.split_on_char ' '
  |> List.filter (fun x -> x <> "")
  |> List.map int_of_string

let read_input fname =
  fname
  |> Advent.read_file
  |> List.map parse_input

let rec monotonic_inc lst =
    match lst with
    | [] | [_] -> true
    | x::y::tl -> x < y && y - x <= 3 && monotonic_inc (y::tl)

let rec monotonic_dec lst =
    match lst with
    | [] | [_] -> true
    | x::y::tl -> x > y && x - y <= 3 && monotonic_dec (y::tl)

let is_monotonic lst =
  match lst with
  | [] | [_] -> true
  | x::y::_ ->
    if x < y then monotonic_inc lst
    else if x > y then monotonic_dec lst
    else false

(* Part 1: a report only counts as safe if both of the following are true:
  - The levels are either all increasing or all decreasing.
  - Any two adjacent levels differ by at least one and at most three. *)
let part1 fname =
  fname
  |> read_input
  |> List.filter is_monotonic
  |> List.length

let non_monotonic lst = not (is_monotonic lst)

let permute_list lst =
  let rec aux prefix rest acc =
    match rest with
    | [] -> acc
    | x :: xs -> aux (x :: prefix) xs ((List.rev_append prefix xs) :: acc)
  in
  aux [] lst []

let monotonic_permutation lst =
  lst
  |> permute_list
  |> List.exists is_monotonic

(* Part 2: The Problem Dampener is a reactor-mounted module that lets the
   reactor safety systems tolerate a single bad level in what would otherwise be
   a safe report. *)
let part2 fname =
  let p1 = part1 fname in
  fname
  |> read_input
  |> List.filter non_monotonic
  |> List.filter monotonic_permutation
  |> List.length
  |> (+) p1
