/* global BigInt */

type Test<T> = [div: T, pos: number, neg: number];

type Monkey<T> = {
  items: T[];
  op: string;
  test: Test<T>;
  touches: number;
};

function parseOperation(opStr: string) {
  return opStr.replace("Operation: new =", "");
}

function last(s: string) {
  const arr = s.split(" ");
  return arr[arr.length - 1];
}

function constructTest(
  testStr: string,
  trueBranch: string,
  falseBranch: string
): Test<number> {
  const test = Number(last(testStr));
  const pos = Number(last(trueBranch));
  const neg = Number(last(falseBranch));
  return [test, pos, neg];
}

export function processInput(input: string): Monkey<number>[] {
  return input
    .trim()
    .split("\n\n")
    .map((monkeyStr) => {
      const [_id, itemStr, opStr, testStr, trueBranch, falseBranch] =
        monkeyStr.split("\n");

      const items = itemStr
        .replace("Starting items: ", "")
        .split(", ")
        .map(Number);
      const op = parseOperation(opStr);
      const test = constructTest(testStr, trueBranch, falseBranch);

      return {
        items,
        op,
        test,
        touches: 0,
      };
    });
}

function doRoundBounded(monkeys: Monkey<number>[]) {
  for (let mIdx = 0; mIdx < monkeys.length; mIdx++) {
    const monkey = monkeys[mIdx];
    const [div, pos, neg] = monkey.test;

    for (const item of monkey.items) {
      const newVal = eval(`${monkey.op.replaceAll("old", item.toString())}`);
      monkey.touches += 1;

      if (newVal % div === 0) {
        monkeys[pos].items.push(newVal);
      } else {
        monkeys[neg].items.push(newVal);
      }
    }

    monkey.items = [];
  }
}

export function part1(monkeys: Monkey<number>[]) {
  // deep copy to preserve for p2
  const mKeys = monkeys.map((m) => {
    return {
      items: Array.from(m.items),
      op: m.op,
      test: m.test,
      touches: 0,
    };
  });

  for (let i = 0; i < 20; i++) {
    doRoundBounded(mKeys);
  }

  const [first, second, ..._rest] = mKeys
    .map((m) => m.touches)
    .sort((a, b) => b - a);
  return first * second;
}

// NOTE: by choosing a base of the LCM of the divisibility tests, we end up with
// an appropriate base that is shared by _all_ of the monkey's divisibility
// checks. this controls for the unbounded growth of the worry value of the
// items as implied by "you'll need to find another way to keep your worry levels manageable"
function doRoundUnbound(monkeys: Monkey<bigint>[], lcm: bigint) {
  for (let mIdx = 0; mIdx < monkeys.length; mIdx++) {
    const monkey = monkeys[mIdx];
    const [div, pos, neg] = monkey.test;

    for (const item of monkey.items) {
      const newVal =
        BigInt(eval(`${monkey.op.replaceAll("old", item.toString())}`)) % lcm;

      monkey.touches += 1;

      if (newVal % div === 0n) {
        monkeys[pos].items.push(newVal);
      } else {
        monkeys[neg].items.push(newVal);
      }
    }

    monkey.items = [];
  }
}

export function part2(monkeys: Monkey<number>[]) {
  const mKeys: Monkey<bigint>[] = monkeys.map((m) => {
    return {
      items: m.items.map((i) => BigInt(i)),
      op: m.op,
      test: [BigInt(m.test[0]), m.test[1], m.test[2]],
      touches: 0,
    };
  });

  // NOTE: all divisibility checks are unique primes, so the LCM is merely the
  // product of the primes
  const lcm: bigint = mKeys
    .map((m) => m.test[0])
    .reduce((a: bigint, b: bigint) => a * b, 1n);

  for (let i = 0; i < 10000; i++) {
    doRoundUnbound(mKeys, lcm);
  }

  const [first, second, ..._rest] = mKeys
    .map((m) => m.touches)
    .sort((a, b) => b - a);
  return first * second;
}
