module buffer

import math

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

pub fn (buf Buffer) get_visual_coords(logical_x int, logical_y int, width int) (int, int) {
	// wraps := logical_x / width
	// x := (logical_x + width) % width
	// y := logical_y + wraps
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

pub fn (mut buf Buffer) update_visual_cursor(width int) {
	buf.visual_cursor.x, buf.visual_cursor.y = buf.get_visual_coords(buf.logical_cursor.x,
		buf.logical_cursor.y, width)
}

pub fn (buf Buffer) logical_x(logical_y int, visual_x int) int {
	if logical_y < 0 || logical_y >= buf.visual_col.len {
		return 0
	}

	visual_line := buf.visual_col[logical_y]
	mut closest := 0

	for i, col in visual_line {
		if col > visual_x {
			break
		}
		closest = i
	}

	return closest
}

pub fn (buf Buffer) visual_y(logical_y int, visual_x int, width int) int {
	mut real_y := 0

	// sum the number of rows all previous lines take
	for row in 0 .. logical_y {
		cur_line := buf.visual_col[row]
		if cur_line.len == 0 {
			real_y++ // empty line is one row
		} else {
			// last visual column / width gives how many wraps this line takes
			real_y += (cur_line.last() / width) + 1
		}
	}

	// add wraps within the current line
	real_y += visual_x / width

	return real_y
}

pub fn (mut buf Buffer) update_offset(visual_wraps int, height int, margin int) bool {
	// Compute the cursor's relative position inside the viewport
	rel_pos := buf.logical_cursor.y - buf.row_offset + visual_wraps

	// Check if cursor is past the bottom margin
	if rel_pos >= height - margin {
		// Scroll so the cursor is `margin` lines from the bottom
		buf.row_offset = buf.logical_cursor.y + visual_wraps - (height - margin) + 1
		return true
	}
	// Check if cursor is above the top margin
	else if buf.logical_cursor.y - buf.row_offset + visual_wraps <= margin {
		// Scroll so the cursor is `margin` lines from the top
		buf.row_offset = math.max(0, buf.logical_cursor.y + visual_wraps - margin)
		return true
	}

	return false
}
