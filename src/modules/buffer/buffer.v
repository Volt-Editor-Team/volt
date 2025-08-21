module buffer

pub fn (mut buf Buffer) update_line_cache(line_index int) {
	line := buf.lines[line_index]
	mut visual := []int{len: line.len}
	mut col := 0

	for i, ch in line.runes() {
		visual[i] = col
		if ch == `\t` {
			col += buf.tabsize - (col % buf.tabsize)
		} else {
			col++
		}
	}
	buf.visual_col[line_index] = visual
}

pub fn (buf Buffer) visual_x(line_index int, logical_x int) int {
	if line_index >= buf.visual_col.len || line_index < 0 {
		return 0
	}

	visual_line := buf.visual_col[line_index]

	if logical_x >= visual_line.len {
		return if visual_line.len > 0 { visual_line[visual_line.len - 1] + 1 } else { 0 }
	}

	return visual_line[logical_x]
}

pub fn (buf Buffer) logical_x(line_index int, visual_x int) int {
	if line_index >= buf.visual_col.len || line_index < 0 {
		return 0
	}

	visual_line := buf.visual_col[line_index]
	mut closest := 0

	for i, col in visual_line {
		if col > visual_x {
			break
		}

		closest = i
	}

	return closest
}

pub fn (mut buf Buffer) insert_char(x_pos int, y_pos int, ch string) {
	mut line := buf.lines[y_pos]
	new_line := line[..x_pos] + ch + line[x_pos..]
	buf.lines[y_pos] = new_line
	buf.update_line_cache(y_pos)
}

pub fn (mut buf Buffer) insert_newline(x_pos int, y_pos int) {
	cur_line := buf.lines[y_pos]
	left := cur_line[..x_pos]
	right := cur_line[x_pos..]

	buf.lines[y_pos] = left
	buf.lines.insert(y_pos + 1, right)
	buf.visual_col.insert(y_pos + 1, []int{})
	buf.update_line_cache(y_pos)
	buf.update_line_cache(y_pos + 1)
}

pub fn (mut buf Buffer) remove_char(x_pos int, y_pos int) DeleteResult {
	cur_line := buf.lines[y_pos]
	left := cur_line[..x_pos]
	right := cur_line[x_pos..]

	mut result := DeleteResult{
		joined_line: false
		new_x:       0
	}

	if x_pos > 0 {
		// normal delete
		buf.lines[y_pos] = left#[..-1] + right
		buf.update_line_cache(y_pos)
		result.new_x = x_pos - 1
	} else if x_pos == 0 && y_pos > 0 {
		// remove line
		buf.remove_line(y_pos)
		prev_line_index := y_pos - 1
		new_x := buf.lines[prev_line_index].len
		buf.lines[y_pos - 1] += right
		buf.update_line_cache(y_pos - 1)

		result.joined_line = true
		result.new_x = new_x
	}
	return result
}

pub fn (mut buf Buffer) remove_line(y_pos int) {
	buf.lines.delete(y_pos)
	buf.visual_col.delete(y_pos)
}
