enum Move {
  Rock = 1,
  Paper,
  Scissors,
}

type Round = [Move, Move];

function opMove(op: string) {
  switch (op) {
    case "A":
      return Move.Rock;
    case "B":
      return Move.Paper;
    default:
      return Move.Scissors;
  }
}

function myMove(me: string) {
  switch (me) {
    case "X":
      return Move.Rock;
    case "Y":
      return Move.Paper;
    default:
      return Move.Scissors;
  }
}

export function processInput(input: string): Round[] {
  return input
    .split("\n")
    .slice(0, -1)
    .map((s) => {
      const [opS, myS] = s.split(" ");
      return [opMove(opS), myMove(myS)];
    });
}

const loses = [Move.Paper, Move.Scissors, Move.Rock];

// if the move at the opponent's location (corrected to zero-based indexing),
// matches our move we win.
function scoreP1(round: Round) {
  const [op, me] = round;

  // draw
  if (op === me) {
    return me + 3;
    // win
  } else if (me === loses[op - 1]) {
    return me + 6;
    // lose
  } else {
    return me;
  }
}

export function part1(rounds: Round[]) {
  return rounds.map(scoreP1).reduce((acc, x) => acc + x, 0);
}

// only the lose case is effectively different, but it relies on the intuition
// that the losing move (i.e. the one we must take) is the move to the right in
// `loses` and wrapping around to the first position as necessary. this is
// effected in two ways: our enum moves us to the position by one already _and_
// `% 3` will wrap us around to Paper if the opponent plays Scissors
function scoreP2(round: Round) {
  const [op, me] = round;

  if (me === Move.Paper) {
    return op + 3;
  } else if (me === Move.Scissors) {
    return loses[op - 1] + 6;
  } else {
    return loses[op % 3];
  }
}

export function part2(rounds: Round[]) {
  return rounds.map(scoreP2).reduce((acc, x) => acc + x, 0);
}
