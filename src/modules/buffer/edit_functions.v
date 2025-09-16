module buffer

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
