function desc(a: number, b: number) {
  return b - a;
}

export function processInput(input: String) {
  return input
    .split("\n\n")
    .map((ls) => ls.split("\n").map(Number))
    .map((xs) => xs.reduce((acc, x) => acc + x, 0));
}

export function part1(input: number[]) {
  return Math.max(...input);
}

export function part2(input: number[]) {
  input.sort(desc);

  const [a, b, c, ..._] = input;

  return a + b + c;
}
