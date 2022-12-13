type Coord = {
  x: number;
  y: number;
};

type HeightMap = {
  start: Coord;
  end: Coord;
  elevs: number[][];
  shortestPaths: number[][];
};

export function processInput(input: string): HeightMap {
  let start: Coord = { x: 0, y: 0 };
  let end: Coord = { x: 0, y: 0 };

  const elevs = input
    .trim()
    .split("\n")
    .map((line, y) => {
      return line.split("").map((char, x) => {
        switch (char) {
          case "S":
            start = { x, y };
            return Infinity;
          case "E":
            end = { x, y };
            return 25; // 'z'.charCodeAt(0) - 97
          default:
            return char.charCodeAt(0) - 97;
        }
      });
    });

  const shortestPaths = shortestPath(end, elevs);

  return {
    start,
    end,
    elevs,
    shortestPaths,
  };
}

function shortestPath(end: Coord, elevs: number[][]): number[][] {
  const visited: boolean[][] = elevs.map((row) => row.map((_) => false));
  const shortestPath: number[][] = elevs.map((row) => row.map((_) => Infinity));

  shortestPath[end.y][end.x] = 0;

  // simulate queue behavior with an array using `shift` and `push`
  const queue: Coord[] = [end];

  // start from the endpoint, try all valid paths; since we start from the end
  // and flood the `shortestPath`s from there, all of the lowest points _and_
  // the start will eventually be reached
  while (queue.length > 0) {
    const curr = queue.shift();
    visited[curr.y][curr.x] = true;

    const cardinalNeighbors = [
      { x: curr.x - 1, y: curr.y },
      { x: curr.x + 1, y: curr.y },
      { x: curr.x, y: curr.y - 1 },
      { x: curr.x, y: curr.y + 1 },
    ].filter(
      ({ x, y }) =>
        x >= 0 && x <= elevs[0].length - 1 && y >= 0 && y <= elevs.length - 1
    );

    cardinalNeighbors.forEach((cardN) => {
      const currElev = elevs[curr.y][curr.x];
      const cardNElev = elevs[cardN.y][cardN.x];

      if (currElev >= cardNElev - 1) {
        const dist = shortestPath[curr.y][curr.x];
        const nDist = shortestPath[cardN.y][cardN.x] + 1;
        shortestPath[curr.y][curr.x] = dist > nDist ? nDist : dist;
      }

      // if the neighbor hasn't been visited _and_ the neighbor would be
      // allowed to choose `curr` as a valid path to the endpoint, enqueue
      if (!visited[cardN.y][cardN.x] && currElev <= cardNElev + 1) {
        queue.push(cardN);
        visited[cardN.y][cardN.x] = true;
      }
    });
  }

  return shortestPath;
}

export function part1(hMap: HeightMap) {
  return hMap.shortestPaths[hMap.start.y][hMap.start.x];
}

export function part2({ elevs: ev, shortestPaths: sp }: HeightMap) {
  const shortestPaths: number[] = [];

  ev.forEach((row, y) => {
    row.forEach((e, x) => {
      if (e === 0) {
        shortestPaths.push(sp[y][x]);
      }
    });
  });

  return Math.min(...shortestPaths);
}
