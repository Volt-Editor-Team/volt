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
