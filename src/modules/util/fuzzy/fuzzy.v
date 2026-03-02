module fuzzy

import strings
import util
// import os

// List of directory or file patterns to ignore
const ignore_patterns = [
	'.git',                 // git metadata
	'.git/*',
	'node_modules',         // node modules
	'node_modules/*',
	'.DS_Store',            // macOS metadata
	'target',               // typical Rust build dir
	'target/*',
	'.cache',               // cache dirs
	'.cache/*',
	'.vs',
	'.vs/*'
	'.idea',                // JetBrains project files
	'.tmp',                 // temp files
	'site-packages',
	'Thumbs.db',
	'__pycache__',
	'__pycache__/*',
	'.next',
	'.nuxt',
	'.exe',
	'venv',
	'venv/*',
	'.venv',
	'.venv/*',
	'env',
	'env/*',
	'.env',
	'.env/*',
	'.app',
	'.app/*',
	'dist',
	'dist/*',
	'build',
	'build/*',
	'.pytest_cache',        // Python test cache
	'.mypy_cache',          // Python type-check cache
	'__pypackages__',       // PEP 582 local packages
	'.tox',                 // Python virtual test environments
	'.eggs',                // Python packaging metadata
	'.egg-info',            // Python packaging metadata
	'build',                // build output folders
	'coverage'              // test coverage output
]

// Check if a file path matches any ignore pattern
pub fn is_ignored(file string) bool {
    for pattern in ignore_patterns {
        if file.match_glob('**/' + pattern) || file.match_glob(pattern) {
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

pub fn fuzzyfind(query string, mut lines [][]rune, mut master_list []string, channel_closed bool) {
	if channel_closed {
		return
	}
	// Preallocate the result array
	mut result := []FuzzyResult{cap: master_list.len}

	// Fill the array
	for entry in master_list {
		if channel_closed {
			return
		}
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
		lines = [][]rune{len: result.len, init: result[index].text.runes()}
	}
}
