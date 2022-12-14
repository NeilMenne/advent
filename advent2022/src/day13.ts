type Val = number | PacketHalf;

type PacketHalf = Array<Val>;

type Packet = {
  left: PacketHalf;
  right: PacketHalf;
};

export function processInput(input: string): Packet[] {
  return input
    .trim()
    .split("\n\n")
    .map((lines) => {
      const [left, right] = lines.split("\n").map(eval);

      return {
        left,
        right,
      };
    });
}

function toPacketHalf(v: Val): PacketHalf {
  return typeof v === "number" ? [v] : v;
}

// number but technically just one of {-1, 0, 1}
function compare(l: PacketHalf, r: PacketHalf): number {
  for (let lIdx = 0; lIdx < l.length; lIdx++) {
    const lVal = l[lIdx];
    const rVal = r[lIdx];

    // left is longer than right
    if (rVal === undefined) return 1;

    if (typeof lVal === "number" && typeof rVal === "number") {
      if (lVal === rVal) {
        continue;
      }

      return lVal < rVal ? -1 : 1;
    }

    const comp = compare(toPacketHalf(lVal), toPacketHalf(rVal));

    if (comp !== 0) return comp;
  }

  return l.length < r.length ? -1 : 0;
}

export function part1(arr: Packet[]) {
  let ans = 0;

  const s = new Set<number>();

  arr.forEach((p, idx) => {
    const cmp = compare(p.left, p.right);

    if (cmp <= 0) {
      ans += idx + 1;
      s.add(idx + 1);
    }
  });

  return ans;
}

export function part2(arr: Packet[]) {
  // exploit the fact that we can look for precisely these arrays by reference
  // since [1] != [1] in JS
  const first = [[2]];
  const second = [[6]];

  const halves: PacketHalf[] = [first, second];

  for (const p of arr) {
    halves.push(p.left);
    halves.push(p.right);
  }

  halves.sort((a, b) => compare(a, b));

  const fIdx = halves.indexOf(first) + 1;
  const sIdx = halves.indexOf(second) + 1;

  return fIdx * sIdx;
}
