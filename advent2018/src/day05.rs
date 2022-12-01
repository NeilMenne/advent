use std::io::prelude::*;
use std::{fs, io};

pub fn solve() {}

fn collapse(s: &str) -> &str {
    s
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn verify_collapse() {
        let s = "dabAcCaCBAcCcaDA";

        assert_eq!(collapse(s), "dabCBAcaDA");
    }
}
