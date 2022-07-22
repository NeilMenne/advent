use std::collections::HashSet;
use std::io::prelude::*;
use std::{fs, io};

pub fn solve() {
    let file = fs::File::open("data/day1.txt").unwrap();
    let lines: Vec<String> = io::BufReader::new(file)
        .lines()
        .map(|l| l.unwrap())
        .collect();

    let values: Vec<i32> = lines.iter().map(|l| l.parse().unwrap()).collect();

    // part 1: Starting with a frequency of zero, what is the resulting
    // frequency after all of the changes in frequency have been applied?
    let mut result = 0;

    for v in &values {
        result += v;
    }

    println!("part 1: {}", result);

    // part 2: What is the first frequency your device reaches twice?
    //
    // NOTE: you might have to repeat its frequency list many times, _and_ you
    // might hit the repeated frequency in the middle of an iteration
    let mut seen = HashSet::new();
    let mut result = 0;

    for v in values.iter().cycle() {
        result += v;

        if seen.contains(&result) {
            println!("part 2: {}", result);
            break;
        } else {
            seen.insert(result);
        }
    }
}
