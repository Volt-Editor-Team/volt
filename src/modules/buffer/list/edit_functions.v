module list

pub fn (mut buf ListBuffer) insert_char(x_pos int, y_pos int, ch rune) {
	// mut line := buf.lines[y_pos]
	// new_line := line[..x_pos] + ch + line[x_pos..]
	// buf.lines[y_pos] = new_line
	buf.lines[y_pos].insert(x_pos, ch)
	// buf.update_line_cache(y_pos)
}

pub fn (mut buf ListBuffer) insert_lines(y_pos int, lines []rune) {
	buf.lines.insert(y_pos, lines)
}

pub fn (mut buf ListBuffer) insert_newline(x_pos int, y_pos int) {
	cur_line := buf.lines[y_pos]
	left := cur_line[..x_pos]
	right := cur_line[x_pos..]

	buf.lines[y_pos] = left
	buf.lines.insert(y_pos + 1, right)
	// buf.visual_col.insert(y_pos + 1, []int{})
	// buf.update_line_cache(y_pos)
	// buf.update_line_cache(y_pos + 1)
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
		line.delete(x_pos)
		buf.lines[y_pos] = line
		return
	}

	// Case 2: at end of line and not last line — delete the "newline" (merge lines)
	if x_pos == line.len && y_pos < buf.lines.len - 1 {
		next_line := buf.lines[y_pos + 1]
		// merge next line into current
		buf.lines[y_pos].insert(buf.lines[y_pos].len, next_line)
		// remove the now redundant next line
		buf.remove_line(y_pos + 1)
		return
	}

	// Case 3: at start of line (x_pos == 0) and not the first line — merge with previous
	if x_pos == 0 && y_pos > 0 {
		prev_idx := y_pos - 1
		prev_line := buf.lines[prev_idx]
		// merge current line into previous
		buf.lines[prev_idx].insert(prev_line.len, line)
		buf.remove_line(y_pos)
		return
	}
}

pub fn (mut buf ListBuffer) remove_line(y_pos int) {
	buf.lines.delete(y_pos)
	// buf.visual_col.delete(y_pos)
}
