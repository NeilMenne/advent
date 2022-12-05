type Range = [number, number];
type Row = [Range, Range];

function toRange(low: string, high: string): Range {
  return [Number(low), Number(high)];
}

export function processInput(input: string): Row[] {
  return input
    .split("\n")
    .slice(0, -1)
    .map((l) => {
      const [left, right] = l.split(",");
      const [ll, lh] = left.split("-");
      const [rl, rh] = right.split("-");

      return [toRange(ll, lh), toRange(rl, rh)];
    });
}

// returns true if either l or r is a subset of the other
function isSubset(l: Range, r: Range) {
  return (l[0] <= r[0] && l[1] >= r[1]) || (l[0] >= r[0] && l[1] <= r[1]);
}

export function part1(input: Row[]) {
  return input.filter((i) => isSubset(i[0], i[1])).length;
}

function anyOverlap(l: Range, r: Range) {
  return (l[0] <= r[0] && l[1] >= r[0]) || (r[0] <= l[0] && r[1] >= l[0]);
}

export function part2(input: Row[]) {
  return input.filter((i) => anyOverlap(i[0], i[1])).length;
}
