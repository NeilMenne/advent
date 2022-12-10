export function processInput(input: string) {
  return input
    .trim()
    .split("\n")
    .flatMap((l) => {
      const [type, val] = l.split(" ");

      if (type === "noop") {
        return [0];
      } else {
        return [0, Number(val)];
      }
    });
}

export function part1(input: number[]) {
  const check = new Set<number>([20, 60, 100, 140, 180, 220]);

  let ans = 0;
  let x = 1;

  for (let cycle = 0; cycle < 220; cycle++) {
    // "during" happens prior to the value being added to the register
    if (check.has(cycle + 1)) {
      ans += x * (cycle + 1);
    }

    x += input[cycle % input.length];
  }

  return ans;
}

export function part2(input: number[]) {
  const crtLines: string[] = [];

  let x = 1;
  let pointer = 0;
  let line: string[] = [];

  for (const i of input) {
    // during the cycle, the pixel is drawn
    line.push(pointer >= x - 1 && pointer <= x + 1 ? "#" : ".");

    // after, changes to the register are visible
    x += i;

    // advance to the next line before the next step
    if (++pointer % 40 === 0) {
      crtLines.push(line.join(""));
      line = [];
      pointer = 0;
    }
  }

  return "\n" + crtLines.join("\n");
}
