let data fname =
  match Advent.read_file fname with
  | [] -> ""
  | lst -> String.concat "" lst

let pattern = Str.regexp {|mul(\([0-9]+\),\([0-9]+\))|}

let extract_muls str =
  let rec extract_mul' idx =
    try
      let nxt = Str.search_forward pattern str idx in
      let a = Str.matched_group 1 str |> int_of_string in
      let b = Str.matched_group 2 str |> int_of_string in
      (a * b) :: extract_mul' (nxt + 1)
    with _ -> []
  in extract_mul' 0

let part1 fname =
  fname
  |> data
  |> extract_muls
  |> List.fold_left (+) 0

let find_all re str =
  let rec find_all' idx =
    try
      let nxt = Str.search_forward re str idx in
      nxt :: find_all' (nxt + 1)
    with _ -> []
  in find_all' 0

type instr =
  | Mul of int * int
  | Do of int
  | Dont of int

(* NOTE: this is not safe in and of itself but it is only called with valid
   indices in practce *)
let mul str idx =
  let _ = Str.search_forward pattern str idx in
  let a = Str.matched_group 1 str |> int_of_string in
  let b = Str.matched_group 2 str |> int_of_string in
  a * b

let muls str = find_all pattern str |> List.map (fun idx -> Mul(idx, mul str idx))
let dos str = find_all (Str.regexp {|do()|}) str |> List.map(fun idx -> Do(idx))
let donts str = find_all (Str.regexp {|don't()|}) str |> List.map(fun idx -> Dont(idx))

let iindex i =
  match i with
  | Mul(i, _) -> i
  | Do i -> i
  | Dont i -> i

let cmp a b = iindex a - iindex b

let all_instrs str =
  let ms = muls str in
  let ds = dos str in
  let dns = donts str in
  [ms; ds; dns]
  |> List.flatten
  |> List.sort cmp

let part2 fname =
  let rec process acc latch instrs =
    match instrs with
    | [] -> acc
    | x :: xs ->
      begin
        match x with
        | Mul(_, m) ->
          if latch then
            process (acc + m) latch xs
          else
            process acc latch xs
        | Do _ -> process acc true xs
        | Dont _ -> process acc false xs
      end
  in
  fname
  |> data
  |> all_instrs
  |> process 0 true
