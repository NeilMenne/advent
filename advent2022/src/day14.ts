type Coord = {
  x: number;
  y: number;
};

type Rocks = Set<string>;

const SAND_ORIG = { x: 500, y: 0 };

function toCoord(str: string): Coord {
  const [x, y] = str.split(",");

  return {
    x: Number(x),
    y: Number(y),
  };
}

function toRange(l: number, r: number): number[] {
  let start = 0;
  let end = 0;

  if (l < r) {
    start = l;
    end = r;
  } else {
    start = r;
    end = l;
  }

  return Array.from(Array(end - start + 1).keys()).map((i) => i + start);
}

function toKey(c: Coord): string {
  return `${c.x}:${c.y}`;
}

function constructRockSet(paths: Coord[][]) {
  const rocks = new Set<string>() as Rocks;

  for (const path of paths) {
    for (let p = 0; p < path.length - 1; p++) {
      const frst = path[p];
      const scnd = path[p + 1];

      // strictly y move (thank the maker for no diagonals)
      if (frst.x === scnd.x) {
        const ys = toRange(frst.y, scnd.y);

        ys.forEach((y) => {
          rocks.add(toKey({ x: frst.x, y }));
        });
      } else {
        const xs = toRange(frst.x, scnd.x);

        xs.forEach((x) => {
          rocks.add(toKey({ x, y: frst.y }));
        });
      }
    }
  }

  return rocks;
}

export function processInput(input: string) {
  const paths = input
    .trim()
    .split("\n")
    .map((line) => {
      return line.split(" -> ").map(toCoord);
    });

  const maxY = Math.max(...paths.flatMap((ps) => ps.map((p) => p.y)));

  return [maxY, constructRockSet(paths)];
}

// extrapolate the current falling grain of sand to all potential positions
function extrapolate(c: Coord): Coord[] {
  return [
    { x: c.x, y: c.y + 1 },
    { x: c.x - 1, y: c.y + 1 },
    { x: c.x + 1, y: c.y + 1 },
  ];
}

function restrict(pos: Coord, occupied: Set<string>) {
  return !occupied.has(toKey(pos));
}

export function part1([maxDepth, rocks]: [number, Rocks]) {
  const occupied = new Set<string>(rocks);

  let grains = 0;
  let curr: Coord = SAND_ORIG;

  // sand falling further than maxDepth means we've filled the cave that we
  // know of and they are continuing to "infinity"
  while (curr.y < maxDepth) {
    const next = extrapolate(curr).filter((pos) => restrict(pos, occupied));

    if (next.length > 0) {
      curr = next[0];
    } else {
      occupied.add(toKey(curr));
      grains++;
      curr = SAND_ORIG;
    }
  }

  return grains;
}

export function part2([maxDepth, rocks]: [number, Rocks]) {
  const occupied = new Set<string>(rocks);
  const floor = maxDepth + 2;
  const origKey = toKey(SAND_ORIG);

  const path: Coord[] = [];
  let grains = 0;
  let curr = SAND_ORIG;

  // for part 2, we terminate when the cave has filled up to the source of the
  // sand there by blocking it
  while (!occupied.has(origKey)) {
    // conveniently, the restriction fn from part 1 needs only a small extension
    // to account for the floor
    const next = extrapolate(curr).filter(
      (pos) => restrict(pos, occupied) && pos.y < floor
    );

    if (next.length > 0) {
      path.push(curr);
      curr = next[0];
    } else {
      occupied.add(toKey(curr));
      curr = path.length > 0 ? path.pop() : SAND_ORIG;
      grains++;
    }
  }

  return grains;
}
