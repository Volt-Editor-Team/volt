module util

pub fn char_expansion_counts(ch u8, tabsize int) int {
	match ch {
		u8(`\t`) {
			return tabsize
		}
		else {
			return 1
		}
	}
}

pub fn char_count_expanded_tabs(line string, tabsize int) int {
	mut res := 0
	for ch in line {
		res += char_expansion_counts(ch, tabsize)
	}
	return res
}

pub fn expand_tabs_to(line string, limit int, tabsize int) int {
	mut res := 0
	mut fin := 0
	mut total := 0
	for i, ch in line {
		if res > limit {
			break
		}
		res += char_expansion_counts(ch, tabsize)
		fin = i
		total++
	}
	if limit > total {
		return fin + 1
	}
	return fin
}
