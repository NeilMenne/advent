export function processInput(input: string) {
  return input.split("\n").slice(0, -1);
}

function intersection<T>(s1: Set<T>, s2: Set<T>): Set<T> {
  const _intersection = new Set<T>();
  for (const i of s1) {
    if (s2.has(i)) {
      _intersection.add(i);
    }
  }

  return _intersection;
}

function calculateValue(c: string): number {
  const val = c.charCodeAt(0);
  // lowercase
  if (val > 95) {
    return val - 96;
  } else {
    return val - 38;
  }
}

export function part1(lines: string[]) {
  return lines
    .map((l) => {
      const mid = l.length / 2;
      const left: Set<string> = new Set([...l.slice(0, mid)]);
      const right: Set<string> = new Set([...l.slice(mid)]);

      const [common] = intersection(left, right);

      return calculateValue(common);
    })
    .reduce((acc, x) => acc + x, 0);
}

export function part2(lines: string[]) {
  let ans = 0;
  for (let i = 0; i < lines.length / 3; i++) {
    const [s1, s2, s3] = lines
      .slice(i * 3, i * 3 + 3)
      .map((l) => new Set<string>([...l]));
    const [common] = intersection(intersection(s1, s2), s3);

    ans += calculateValue(common);
  }

  return ans;
}
