module fuzzy

import strings

struct FuzzyResult {
	text       string
	score      f64
	highlights []f64 // for highlighting matched characters
}

pub fn fuzzyfind(query string, mut lines []string, mut stop_flag &bool) {
	if *stop_flag {
		return
	}

	// Preallocate the result array
	mut result := []FuzzyResult{len: lines.len}

	// Fill the array
	for i, entry in lines {
		if *stop_flag {
			return
		}
		result[i] = FuzzyResult{
			text:  entry
			score: strings.jaro_winkler_similarity(query.to_lower(), entry.to_lower())
		}
	}

	// Sort after filling
	// result = result.filter(it.score >= 0)
	result.sort(a.score > b.score)

	// Fill lines safely inside the lock
	lock {
		lines = []string{len: result.len, init: result[index].text}
	}
}
