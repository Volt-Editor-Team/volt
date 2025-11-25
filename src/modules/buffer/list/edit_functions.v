module list

pub fn (mut buf ListBuffer) insert_char(x_pos int, y_pos int, ch rune) {
	// buf.lines[y_pos].insert(x_pos, ch)

	buf.lines[y_pos] = buf.lines[y_pos][..x_pos] + ch.str() + buf.lines[y_pos][x_pos..]
}

pub fn (mut buf ListBuffer) insert_slice(x_pos int, y_pos int, runes []rune) {
	if runes.len == 1 && runes.first() == `\n` {
		buf.insert_newline(x_pos, y_pos)
		return
	}

	// mut lines := [][]rune{}
	// mut cur_line := []rune{}
	// for ch in runes {
	// 	if ch == `\n` {
	// 		lines << cur_line
	// 		cur_line = []rune{}
	// 	} else {
	// 		cur_line << ch
	// 	}
	// }
	// if cur_line.len > 0 {
	// 	lines << cur_line
	// }
	lines := runes.string().split_into_lines()

	// buf.lines[y_pos].insert(x_pos, lines[0])
	buf.lines[y_pos] = buf.lines[y_pos][..x_pos] + lines[0]
	if lines.len > 1 {
		buf.lines.insert(y_pos + 1, lines[1..])
	}
}

pub fn (mut buf ListBuffer) insert_line(y_pos int, lines []rune) {
	buf.lines.insert(y_pos, lines.string())
}

pub fn (mut buf ListBuffer) insert_newline(x_pos int, y_pos int) {
	cur := buf.lines[y_pos]

	// Right side becomes the new line
	right := cur[x_pos..]

	// Left side remains as current line
	buf.lines[y_pos] = cur[..x_pos]

	// Insert right side below
	buf.lines.insert(y_pos + 1, right)
}

pub fn (mut buf ListBuffer) remove_char(x_pos int, y_pos int) {
	// Out of bounds check
	if y_pos < 0 || y_pos >= buf.lines.len {
		return
	}
	if x_pos < 0 {
		return
	}

	// Convenience
	mut line := buf.lines[y_pos]

	// Case 1: delete a normal character inside the line
	if x_pos < line.len {
		// line.delete(x_pos)
		line = line[..x_pos] + line#[x_pos + 1..]
		buf.lines[y_pos] = line
		return
	}

	// Case 2: at end of line and not last line — delete the "newline" (merge lines)
	if x_pos == line.len && y_pos < buf.lines.len - 1 {
		next_line := buf.lines[y_pos + 1]
		// merge next line into current
		// buf.lines[y_pos].insert(buf.lines[y_pos].len, next_line)
		buf.lines[y_pos] += next_line
		// remove the now redundant next line
		buf.remove_line(y_pos + 1)
		return
	}

	// Case 3: at start of line (x_pos == 0) and not the first line — merge with previous
	if x_pos == 0 && y_pos > 0 {
		prev_idx := y_pos - 1
		// merge current line into previous
		// buf.lines[prev_idx].insert(prev_line.len, line)
		buf.lines[prev_idx] += line
		buf.remove_line(y_pos)
		return
	}
}

pub fn (mut buf ListBuffer) remove_line(y_pos int) {
	buf.lines.delete(y_pos)
	// buf.visual_col.delete(y_pos)
}
