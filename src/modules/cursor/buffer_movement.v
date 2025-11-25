module cursor

import util

pub fn (mut log_curs LogicalCursor) move_right_buffer(vp_lines [][]rune, row_offset int, tabsize int) {
	relative_y := log_curs.y - row_offset
	cur_line := vp_lines[relative_y]
	if log_curs.x < cur_line.len {
		log_curs.x++
		log_curs.flat_index++
		log_curs.increment_visual_x(cur_line, tabsize)
	} else if relative_y < vp_lines.len - 1 {
		log_curs.x = 0
		log_curs.y++
		log_curs.flat_index++
		if cur_line.len == 0 {
			log_curs.visual_x = 1
		} else {
			log_curs.visual_x = util.get_char_width(cur_line[0], tabsize)
		}
	}
}

pub fn (mut log_curs LogicalCursor) move_left_buffer(vp_lines [][]rune, row_offset int, tabsize int) {
	relative_y := log_curs.y - row_offset
	cur_line := vp_lines[relative_y]
	if log_curs.x == 0 {
		if relative_y > 0 {
			log_curs.y -= 1
			new_cur_line := vp_lines[relative_y - 1]
			log_curs.x = new_cur_line.len
			log_curs.flat_index--
			log_curs.set_visual_x(new_cur_line, tabsize)
		}
	} else {
		log_curs.x -= 1
		log_curs.flat_index--
		log_curs.decrement_visual_x(cur_line, tabsize)
	}
}

pub fn (mut log_curs LogicalCursor) move_down_buffer(vp_lines [][]rune, row_offset int, tabsize int) {
	relative_y := log_curs.y - row_offset
	mut cur_line := vp_lines[relative_y]
	// cursor is not on the last line
	// move curse down and calculate x
	if relative_y < vp_lines.len - 1 {
		line := cur_line
		log_curs.flat_index += line.len + 1 - log_curs.x
		log_curs.y += 1
		cur_line = vp_lines[relative_y + 1]
		mut column := 0
		mut closest := 0
		for i, ch in cur_line {
			if column >= log_curs.desired_col {
				break
			}
			column += if ch == `\t` { tabsize - (column % tabsize) } else { 1 }
			closest = i
		}
		log_curs.x = if closest == cur_line.len - 1 && column < log_curs.desired_col {
			closest + 1
		} else {
			closest
		}
		log_curs.flat_index += log_curs.x
	} else {
		// cursor is on the last line
		// move cursor the end
		log_curs.flat_index += cur_line.len - log_curs.x
		log_curs.x = cur_line.len
	}
	log_curs.set_visual_x(cur_line, tabsize)
}

pub fn (mut log_curs LogicalCursor) move_up_buffer(vp_lines [][]rune, row_offset int, tabsize int) {
	relative_y := log_curs.y - row_offset
	mut cur_line := vp_lines[relative_y]
	log_curs.flat_index -= log_curs.x
	if log_curs.y > 0 {
		log_curs.y -= 1
		cur_line = vp_lines[relative_y - 1]
		mut column := 0
		mut closest := 0
		for i, ch in cur_line {
			if column >= log_curs.desired_col {
				break
			}
			column += if ch == `\t` { tabsize - (column % tabsize) } else { 1 }
			closest = i
		}
		log_curs.x = if closest == cur_line.len - 1 && column < log_curs.desired_col {
			closest + 1
		} else {
			closest
		}
		log_curs.flat_index -= cur_line.len + 1 - log_curs.x
	} else if log_curs.y == 0 {
		log_curs.x = 0
	}
	log_curs.set_visual_x(cur_line, tabsize)
}

pub fn (mut log_curs LogicalCursor) move_to_start_next_line_buffer(vp_lines [][]rune, row_offset int, tabsize int) {
	log_curs.move_down_buffer(vp_lines, row_offset, tabsize)
	prev_x := log_curs.x
	log_curs.x = 0
	log_curs.flat_index -= prev_x
	log_curs.set_visual_x(vp_lines[log_curs.y - row_offset], tabsize)
}

pub fn (mut log_curs LogicalCursor) move_to_x_next_line_buffer(x int, vp_lines [][]rune, row_offset int, tabsize int) {
	// log_curs.move_down_buffer(mut cur_line, buf, tabsize)
	// prev_x := log_curs.x
	// line := buf.line_at(log_curs.y)
	// log_curs.x = line.len
	// log_curs.flat_index += line.len - prev_x
	// log_curs.set_visual_x(buf.line_at(log_curs.y), tabsize)
	cur_line := vp_lines[log_curs.y - row_offset]
	log_curs.move_to_start_next_line_buffer(vp_lines, row_offset, tabsize)
	log_curs.move_to_x(cur_line, x, tabsize)
}

pub fn (mut log_curs LogicalCursor) move_to_end_previous_line_buffer(vp_lines [][]rune, row_offset int, tabsize int) {
	log_curs.move_up_buffer(vp_lines, row_offset, tabsize)
	prev_x := log_curs.x
	line := vp_lines[log_curs.y - row_offset]
	log_curs.x = line.len
	log_curs.flat_index += log_curs.x - prev_x
	log_curs.set_visual_x(line, tabsize)
}
