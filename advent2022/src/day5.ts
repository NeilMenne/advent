type Move = {
  count: number;
  source: number;
  dest: number;
};

type State = {
  stacks: string[][];
  moves: Move[];
};

// NOTE: "top" of the stack is the last element of each array; this is amenable
// since both push and pop work against the tails of the arrays
function initializeStacks(stackStrs: string[]): string[][] {
  const stacks: string[][] = [];

  for (let i = 0; i < stackStrs[0].length / 4; i++) {
    stacks.push([]);
  }

  for (const str of stackStrs) {
    const row = str.split("");

    // strings are not padded on the end
    for (let idx = 0; idx < str.length / 4; idx++) {
      const val = row[4 * idx + 1];

      if (val != " ") {
        stacks[idx].push(val);
      }
    }
  }

  return stacks;
}

function initializeMoves(moveStrs: string[]): any[] {
  return moveStrs.map((move) => {
    const [count, source, dest] = move.match(/[0-9]+/g).map(Number);

    // NOTE: zero-based index conversion for `source` and `dest`
    return {
      count,
      source: source - 1,
      dest: dest - 1,
    };
  });
}

export function processInput(input: string): State {
  const [stackStr, moveStr] = input.split("\n\n");

  const stacks = initializeStacks(stackStr.split("\n").slice(0, -1).reverse());
  const moves = initializeMoves(moveStr.split("\n").slice(0, -1));

  return { stacks, moves };
}

function applyMove9000(stacks: string[][], move: Move) {
  for (let i = 0; i < move.count; i++) {
    const val = stacks[move.source].pop();
    stacks[move.dest].push(val);
  }
}

// NOTE: since we're relying on `forEach` to mutate the stacks, we make a copy
// of the input to preserve the originals for P2.
export function part1(input: State) {
  const stacks = input.stacks.map((s) => Array.from(s));

  input.moves.forEach((mv) => applyMove9000(stacks, mv));

  return stacks.map((stack) => stack[stack.length - 1]).join("");
}

function applyMove9001(stacks: string[][], move: Move) {
  stacks[move.dest].push(...stacks[move.source].slice(-move.count));

  for (let i = 0; i < move.count; i++) {
    stacks[move.source].pop();
  }
}

export function part2(input: State) {
  const stacks = input.stacks.map((s) => Array.from(s));
  input.moves.forEach((mv) => applyMove9001(stacks, mv));
  return stacks.map((stack) => stack[stack.length - 1]).join("");
}
