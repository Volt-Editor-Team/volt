module util

fn char_expansion_counts(ch u8, tabsize int) int {
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
