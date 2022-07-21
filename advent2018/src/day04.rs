use std::collections::HashMap;
use std::io::prelude::*;
use std::{fs, io};

use lazy_static::lazy_static;
use regex::Regex;

lazy_static! {
    static ref GUARD_REGEX: Regex = Regex::new(
        r#"\[\d{4}-\d{2}-\d{2} \d{2}:(?P<minute>\d+)\] (?:Guard \#(?P<id>[0-9]+) begins shift|(?P<state>.+))"#
    ).unwrap();
}

enum EntryType {
    Start { id: u32 },
    FallAsleep,
    WakeUp
}

struct Entry {
    entry_type: EntryType,
    minute: u32
}

impl Entry {
    fn new(line: &str) -> Entry {
        let caps = GUARD_REGEX.captures(line).unwrap();

        let et =
            if let Some(id) = caps.name("id") {
                EntryType::Start { id: id.as_str().parse().unwrap() }
            } else if &caps["state"] == "falls asleep" {
                EntryType::FallAsleep
            } else {
                EntryType::WakeUp
            };

        Entry {
            entry_type: et,
            minute: caps["minute"].parse().unwrap(),
        }
    }
}

pub fn solve() {
    // NOTE: file was lexically sorted in the shell
    let file = fs::File::open("data/day4.txt").unwrap();
    let lines: Vec<String> = io::BufReader::new(file)
        .lines()
        .map(|l| l.unwrap())
        .collect();

    let entries: Vec<Entry> = lines.iter().map(|l| Entry::new(l)).collect();

    let mut shift_map : HashMap<u32, Vec<Entry>> = HashMap::new();
    let mut guard_id = 0;

    for e in entries {
        // NOTE: shift starts are only useful for capturing the current guard id so
        // they set `guard_id` and are ignored thereafter
        if let EntryType::Start{ id } = e.entry_type {
            guard_id = id;
        } else {
            shift_map.entry(guard_id).or_default().push(e);
        }
    }

    // part 1: we must simultaneously track _both_ the total number of minutes
    // slept per-guard per-minute _and_ the total number of minutes per-guard
    let mut sleep_map : HashMap<(u32, u32), u32> = HashMap::new();
    let mut total_sleep: HashMap<u32, usize> = HashMap::new();

    for (&id, es) in shift_map.iter() {
        // NOTE: analysis of the file shows that every "falls asleep" is
        // immediately followed by a "wakes up" entry _and_ we dropped the shift
        // starts, so we're guaranteed chunks of two
        for chunk in es.chunks_exact(2) {
            let range = chunk[0].minute..chunk[1].minute;

            *total_sleep.entry(id).or_default() += range.len();

            for m in range {
                *sleep_map.entry((id, m)).or_default() += 1;
            }
        }
    }

    let (guard_id, _) = total_sleep
        .iter()
        .max_by_key(|&(_id, total_minutes)| total_minutes)
        .unwrap();

    let ((_, minute), _) = sleep_map
        .iter()
        .filter(|&((id, _min), _)| id == guard_id)
        .max_by_key(|&(_key, s)| s)
        .unwrap();

    println!("part 1: {}", guard_id * minute);

    // part 2: use the per-guard per-minute map to find the max
    let ((guard_id, minute), _) = sleep_map
        .iter()
        .max_by_key(|&(_key, s)| s)
        .unwrap();

    println!("part 2: {}", guard_id * minute);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn verify_shift() {
        let line = "[1518-01-19 00:03] Guard #1021 begins shift";

        assert!(GUARD_REGEX.is_match(line));

        let caps = GUARD_REGEX.captures(line).unwrap();
        assert_eq!(&caps["id"], "1021");
    }

    #[test]
    fn verify_sleep() {
        let line = "[1518-01-19 00:19] falls asleep";

        assert!(GUARD_REGEX.is_match(line));

        let caps = GUARD_REGEX.captures(line).unwrap();
        assert_eq!(&caps["state"], "falls asleep");
    }

    #[test]
    fn verify_wakeup() {
        let line = "[1518-01-19 00:55] wakes up";

        assert!(GUARD_REGEX.is_match(line));

        let caps = GUARD_REGEX.captures(line).unwrap();
        assert_eq!(&caps["state"], "wakes up");
    }

}
