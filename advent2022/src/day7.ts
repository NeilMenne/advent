function putNew(m: Map<string, number>, k: string, v?: number) {
  if (!m.has(k)) {
    m.set(k, v ? v : 0);
  }
}

export function processInput(input: string) {
  const lines = input.trim().split("\n");
  const dirs = new Map<string, number>([["/", 0]]);

  let path = [];

  for (let i = 0; i < lines.length; i++) {
    const [type, cmd, dest] = lines[i].split(" ");

    // ls commands are silently ignored
    if (type === "$") {
      if (cmd === "cd") {
        if (dest === "/") {
          path = [];
        } else if (dest === "..") {
          path.pop();
        } else {
          path.push(dest);
        }
      }

      // dir commands ensure that the directory's size is initialized
    } else if (type === "dir") {
      path.push(cmd);
      const key = "/" + path.join("/");
      putNew(dirs, key);
      path.pop();

      // every other `type` is actually a file size
    } else {
      const size = Number(type);

      for (let j = path.length; j >= 0; j--) {
        const key = "/" + path.slice(0, j).join("/");
        dirs.set(key, dirs.get(key)! + size);
      }
    }
  }

  return dirs;
}

export function part1(input: Map<string, number>) {
  const sizeArr = [...input.values()];

  return sizeArr.filter((s) => s <= 100000).reduce((acc, x) => acc + x, 0);
}

export function part2(input: Map<string, number>) {
  const usedSpace = 70000000 - input.get("/");
  const requiredSpace = 30000000 - usedSpace;
  const sizeArr = [...input.values()];

  return Math.min(...sizeArr.filter((s) => s >= requiredSpace));
}
