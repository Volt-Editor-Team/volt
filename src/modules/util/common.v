module util

pub fn get_char_width(ch rune, tabsize int) int {
	match ch {
		`\t` {
			return tabsize
		}
		else {
			return 1
		}
	}
}

pub fn expand_line_to(line []rune, x int, tabsize int) int {
	mut res := 0
	for i, ch in line {
		if i > x {
			break
		}
		res += get_char_width(ch, tabsize)
	}

	return res
}

pub fn char_count_expanded_tabs(line string, tabsize int) int {
	mut res := 0
	for ch in line {
		res += get_char_width(ch, tabsize)
	}
	return res
}

pub fn expand_tabs_to(line string, limit int, tabsize int) int {
	mut res := 0
	mut fin := 0
	for i, ch in line {
		if res > limit {
			break
		}
		res += get_char_width(ch, tabsize)
		fin = i
	}
	if limit > line.runes().len {
		return fin + 1
	}
	return fin
}
