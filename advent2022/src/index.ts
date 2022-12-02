import { readFileSync } from "fs";
const day = process.argv[2];
const test = process.argv[3];

const input = readFileSync(
  test ? `data/day${day}_test.txt` : `data/day${day}.txt`,
  { encoding: "ascii" }
);

const { processInput, part1, part2 } = require(`./day${day}`);

const processed = processInput(input);

let ans = part1(processed);

console.log(`Day ${day} Part 1: ${ans}`);

ans = part2(processed);

console.log(`Day ${day} Part 2: ${ans}`);
