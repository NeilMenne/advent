enum Direction {
  Right = "R",
  Left = "L",
  Up = "U",
  Down = "D",
}

type Instruction = [Direction, number];

type Coord = [x: number, y: number];

export function processInput(input: string): Instruction[] {
  return input
    .trim()
    .split("\n")
    .map((s) => {
      const [dir, num] = s.split(" ");
      return [<Direction>dir, Number(num)];
    });
}

function chebyshevDists(tail: Coord, head: Coord) {
  return head.map((xi, i) => xi - tail[i]);
}

function moveHead(head: Coord, dir: Direction) {
  switch (dir) {
    case Direction.Right:
      head[0] += 1;
      break;
    case Direction.Left:
      head[0] -= 1;
      break;
    case Direction.Up:
      head[1] += 1;
      break;
    case Direction.Down:
      head[1] -= 1;
      break;
  }
}

function moveTail(curr: Coord, prev: Coord) {
  const dX = prev[0] - curr[0];
  const dY = prev[1] - curr[1];

  curr[0] += dX / Math.abs(dX) || 0;
  curr[1] += dY / Math.abs(dY) || 0;
}

function visit(tail: Coord, visited: Set<string>) {
  const posStr = tail.join(":");
  visited.add(posStr);
}

function applyMove(
  head: Coord,
  knots: Coord[],
  instr: Instruction,
  visited: Set<string>
) {
  for (let dist = instr[1]; dist > 0; dist--) {
    moveHead(head, instr[0]);

    let prev = head;

    for (let kIdx = 0; kIdx < knots.length; kIdx++) {
      if (kIdx > 0) {
        prev = knots[kIdx - 1];
      }

      const curr = knots[kIdx];

      const dists = chebyshevDists(curr, prev);

      if (Math.max(...dists.map(Math.abs)) > 1) {
        moveTail(curr, prev);
      }

      if (kIdx == knots.length - 1) {
        visit(curr, visited);
      }
    }
  }
}

export function part1(instrs: Instruction[]) {
  const head: Coord = [0, 0];
  const knots: Coord[] = [[0, 0]];
  const visited = new Set<string>(["0:0"]);

  instrs.forEach((instr) => applyMove(head, knots, instr, visited));
  return visited.size;
}

export function part2(instrs: Instruction[]) {
  const head: Coord = [0, 0];

  const knots: Coord[] = [];
  for (let i = 0; i < 9; i++) {
    knots.push([0, 0]);
  }

  const visited = new Set<string>(["0:0"]);

  instrs.forEach((instr) => applyMove(head, knots, instr, visited));

  return visited.size;
}
