module buffer

pub fn (mut buf Buffer) update_all_line_cache() {
	for i in 0 .. buf.lines.len {
		buf.update_line_cache(i)
	}
}

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

pub fn (buf Buffer) get_visual_coords(logical_x int, logical_y int) (int, int) {
	if logical_y >= buf.visual_col.len || logical_y < 0 {
		return 0, logical_y
	}

	visual_line := buf.visual_col[logical_y]

	if logical_x >= visual_line.len {
		return if visual_line.len > 0 {
			visual_line[visual_line.len - 1] + 1, logical_y
		} else {
			0, logical_y
		}
	}

	return visual_line[logical_x], logical_y
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
