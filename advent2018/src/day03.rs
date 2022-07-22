use std::collections::HashMap;
use std::io::prelude::*;
use std::{fs, io};

use lazy_static::lazy_static;
use regex::Regex;

lazy_static! {
    static ref CLAIM_REGEX: Regex = Regex::new(r#"\#(?P<id>[0-9]+) @ (?P<left>[0-9]+),(?P<top>[0-9]+): (?P<width>[0-9]+)x(?P<height>[0-9]+)"#).unwrap();
}

struct Claim {
    id: u32,
    left: u32,
    top: u32,
    width: u32,
    height: u32,
}

impl Claim {
    fn new(line: &str) -> Claim {
        let caps = CLAIM_REGEX.captures(line).unwrap();

        Claim {
            id: caps["id"].parse().unwrap(),
            left: caps["left"].parse().unwrap(),
            top: caps["top"].parse().unwrap(),
            width: caps["width"].parse().unwrap(),
            height: caps["height"].parse().unwrap(),
        }
    }
}

// inspired by https://ramblingsin3d.xyz/rust-iterators-for-custom-collections/
impl<'s> IntoIterator for &'s Claim {
    // We can refer to this type using Self::Item
    type Item = (u32, u32);
    type IntoIter = PointIterator<'s>;

    fn into_iter(self) -> Self::IntoIter {
        PointIterator {
            x: self.left,
            y: self.top,
            claim: self,
        }
    }
}

struct PointIterator<'a> {
    x: u32,
    y: u32,
    claim: &'a Claim,
}

impl<'s> Iterator for PointIterator<'s> {
    type Item = (u32, u32);

    fn next(&mut self) -> Option<Self::Item> {
        // on row complete, reset x, increment y
        if self.x >= self.claim.left + self.claim.width {
            self.x = self.claim.left;
            self.y += 1;
        }

        if self.y >= self.claim.top + self.claim.height {
            return None;
        }

        let x = self.x;
        let y = self.y;
        self.x += 1;
        Some((x, y))
    }
}

pub fn solve() {
    let file = fs::File::open("data/day3.txt").unwrap();
    let lines: Vec<String> = io::BufReader::new(file)
        .lines()
        .map(|l| l.unwrap())
        .collect();

    let claims: Vec<Claim> = lines.iter().map(|l| Claim::new(l)).collect();

    let mut grid: HashMap<(u32, u32), u32> = HashMap::new();

    for claim in &claims {
        for p in claim.into_iter() {
            *grid.entry(p).or_default() += 1;
        }
    }

    let res: usize = grid.values().filter(|&c| c > &1).count();
    println!("part one: {}", res);

    for claim in &claims {
        if claim.into_iter().all(|p| grid[&p] == 1) {
            println!("part two: {}", claim.id);
            break;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn verify_regex() {
        assert!(CLAIM_REGEX.is_match("#123 @ 3,2: 5x4"));

        let caps = CLAIM_REGEX.captures("#123 @ 3,2: 5x4").unwrap();

        assert_eq!(caps["id"], String::from("123"));
        assert_eq!(caps["left"], String::from("3"));
        assert_eq!(caps["top"], String::from("2"));
        assert_eq!(caps["width"], String::from("5"));
        assert_eq!(caps["height"], String::from("4"));
    }

    #[test]
    fn extrapolate_points() {
        let claim = Claim {
            id: 1,
            left: 0,
            top: 0,
            width: 3,
            height: 3,
        };

        let points: Vec<(u32, u32)> = claim.into_iter().collect();

        let expect = vec![
            (0, 0),
            (1, 0),
            (2, 0),
            (0, 1),
            (1, 1),
            (2, 1),
            (0, 2),
            (1, 2),
            (2, 2),
        ];

        assert_eq!(points, expect);
    }
}
