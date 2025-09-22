module fuzzy

import os

struct FuzzyResult {
	text       string
	score      f64
	highlights []int // for highlighting matched characters
}

pub fn fuzzyfind(query string, base_path string) {
	entries := os.ls(base_path) or { [''] }
}
