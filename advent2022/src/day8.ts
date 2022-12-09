export function processInput(input: string) {
  return input
    .trim()
    .split("\n")
    .map((line) => {
      const [...chars] = line;

      return chars.map(Number);
    });
}

// clockwise rotation from SO
function rotate<T>(matrix: T[][]) {
  return matrix[0].map((_val, index) =>
    matrix.map((row) => row[index]).reverse()
  );
}

function isEdge(x: number, y: number, trees: number[][]) {
  return x == 0 || x == trees[0].length - 1 || y == 0 || y == trees.length - 1;
}

// for part 2, it matters that the results are from the perspective of the current element, so we reverse the order for `countVisible`
function leftOf(index: number, row: number[]) {
  return row.slice(0, index).reverse();
}

function rightOf(index: number, row: number[]) {
  return row.slice(index + 1);
}

// a tree is visible if along _any_ of the cardinal directions, there is an
// unobstructed view to the edge (e.g. where every tree in that direction is
// shorter than the current one).
function isVisible(currTree: number, sightLines: number[][]) {
  return sightLines.some((sightLine) =>
    sightLine.every((tree) => tree < currTree)
  );
}

export function part1(trees: number[][]) {
  const cols = rotate(trees);
  let visible = 0;

  trees.forEach((row, y) => {
    row.forEach((tree, x) => {
      if (isEdge(x, y, trees)) {
        visible += 1;
      } else {
        const col = cols[x];

        // in order: left, right, below, above.
        //
        // since we rotated clockwise, the column indexing appears odd but the
        // 0th position is actually col.length - 1
        const sightLines = [
          leftOf(x, row),
          rightOf(x, row),
          leftOf(col.length - 1 - y, col),
          rightOf(col.length - 1 - y, col),
        ];

        if (isVisible(tree, sightLines)) {
          visible += 1;
        }
      }
    });
  });

  return visible;
}

function countVisible(currTree: number, sightLine: number[]) {
  const idx = sightLine.findIndex((tree) => tree >= currTree);

  return idx >= 0 ? idx + 1 : sightLine.length;
}

export function part2(trees: number[][]) {
  const scores: number[] = [];

  const cols = rotate(trees);

  trees.forEach((row, y) => {
    row.forEach((tree, x) => {
      // ignore edges which have _at least_ one zero since we're multiplying
      if (!isEdge(x, y, trees)) {
        const col = cols[x];
        const sightLines = [
          leftOf(x, row),
          rightOf(x, row),
          leftOf(col.length - 1 - y, col),
          rightOf(col.length - 1 - y, col),
        ];

        const score = sightLines
          .map((sightLine) => countVisible(tree, sightLine))
          .reduce((acc, y) => acc * y, 1);

        scores.push(score);
      }
    });
  });

  return Math.max(...scores);
}
