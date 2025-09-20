module util

pub fn get_char_and_width(ch rune, index int, tabsize int) (rune, int) {
	if ch == `\t` {
		return ` `, tabsize - (index % tabsize)
	}

	return ch, 1
}
