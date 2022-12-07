export function processInput(input: string) {
  return input.trim();
}

function distinctChars(arr: string[], startIdx: number, size: number = 4) {
  const s = new Set(arr.slice(startIdx, startIdx + size));
  return s.size == size;
}

export function part1(input: string) {
  const arr = [...input];
  for (let i = 0; i < arr.length; i++) {
    if (distinctChars(arr, i)) {
      return i + 4;
    }
  }

  return -1;
}

export function part2(input: string) {
  const arr = [...input];
  for (let i = 0; i < arr.length; i++) {
    if (distinctChars(arr, i, 14)) {
      return i + 14;
    }
  }

  return -1;
}
