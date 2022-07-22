use std::collections::HashMap;
use std::io::prelude::*;
use std::{fs, io};

pub fn solve() {
    let file = fs::File::open("data/day2.txt").unwrap();
    let lines: Vec<String> = io::BufReader::new(file)
        .lines()
        .map(|l| l.unwrap())
        .collect();

    // part 1
    let mut twos = 0;
    let mut threes = 0;

    for l in &lines {
        let mut char_map: HashMap<char, i32> = HashMap::new();

        for c in l.chars() {
            let entry = char_map.entry(c).or_insert(0);
            *entry += 1;
        }

        if char_map.values().any(|&x| x == 2) {
            twos += 1;
        }

        if char_map.values().any(|&x| x == 3) {
            threes += 1;
        }
    }

    let result = twos * threes;
    println!("part 1: {}", result);

    // part 2
    for i in 0..lines.len() {
        for j in i + 1..lines.len() {
            if one_diff(&lines[i], &lines[j]) {
                let ans = common_chars(&lines[i], &lines[j]);

                println!("part 2: {}", ans);
                break;
            }
        }
    }
}

fn one_diff(a: &str, b: &str) -> bool {
    let mut err = false;

    for (ac, bc) in a.chars().zip(b.chars()) {
        if ac != bc && err {
            return false;
        }

        err = true;
    }

    err
}

fn common_chars(a: &str, b: &str) -> String {
    a.chars()
        .zip(b.chars())
        .filter(|&(ac, bc)| ac == bc)
        .map(|(ac, _)| ac)
        .collect()
}
