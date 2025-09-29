module fuzzy

import strings
import util
import os

// List of directory or file patterns to ignore
const ignore_patterns = [
	'.git', // git metadata
	'node_modules', // node modules
	'.DS_Store', // macOS metadata
	'target', // typical Rust build dir
	'.cache', // cache dirs
	'.vscode', // editor config
	'.idea', // JetBrains project files
	'.tmp', // temp files
	'site-packages',
	'Thumbs.db',
	'__pycache__',
	'.next',
	'.nuxt',
	'.exe',
]

// Check if a file path matches any ignore pattern
pub fn is_ignored(file string) bool {
	for pattern in ignore_patterns {
		// Match folder or file anywhere in path
		if file.contains(os.path_separator + pattern + os.path_separator)
			|| file.ends_with(os.path_separator + pattern) || file.ends_with(pattern) {
			return true
		}
	}
	return false
}

struct FuzzyResult {
	text       string
	score      f64
	highlights []f64 // for highlighting matched characters
}

fn compare_fuzzy_result(a FuzzyResult, b FuzzyResult) int {
	if a.score < b.score {
		return -1
	} else if a.score > b.score {
		return 1
	} else {
		return 0
	}
}

pub fn fuzzyfind(query string, mut lines []string, mut master_list []string) {
	// Preallocate the result array
	mut result := []FuzzyResult{cap: master_list.len}

	// Fill the array
	for entry in master_list {
		q := query.to_lower()
		e := entry.to_lower()
		if util.is_subsequence(q, e) {
			fzf_entry := FuzzyResult{
				text:  entry
				score: if master_list.len > 2000 {
					strings.jaro_winkler_similarity(q, e)
				} else {
					strings.levenshtein_distance_percentage(q, e)
				}
			}
			// Sort using binary search
			util.binary_insert(mut result, fzf_entry, compare_fuzzy_result)
		}
	}

	// Fill lines safely inside the lock
	lock {
		lines = []string{len: result.len, init: result[index].text}
	}
}
