module util

pub fn flatten_lines(lines [][]rune) ([]rune, int) {
	mut total_runes := 0
	for line in lines {
		total_runes += line.len + 1
	}
	mut runes := []rune{cap: total_runes}
	for line in lines {
		runes << line
	}

	return runes, lines.len
}

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

pub fn char_count_expanded_tabs(line []rune, tabsize int) int {
	mut res := 0
	for ch in line {
		res += get_char_width(ch, tabsize)
	}
	return res
}

pub fn expand_tabs_to(line []rune, limit int, tabsize int) int {
	mut res := 0
	mut fin := 0
	for i, ch in line {
		if res > limit {
			break
		}
		res += get_char_width(ch, tabsize)
		fin = i
	}
	if limit > line.len {
		return fin + 1
	}
	return fin
}
