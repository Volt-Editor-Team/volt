module cursor

import buffer.common { BufferInterface }

pub fn (mut log_curs LogicalCursor) move_right_buffer(mut cur_line []rune, buf BufferInterface, tabsize int) {
	if log_curs.x < cur_line.len {
		log_curs.x++
		log_curs.flat_index++
		log_curs.increment_visual_x(cur_line, tabsize)
	} else if log_curs.y < buf.line_count() - 1 {
		log_curs.x = 0
		log_curs.y++
		log_curs.flat_index++
		cur_line = buf.line_at(log_curs.y) // change cur line sense moving to next line
		log_curs.set_visual_x(cur_line, tabsize)
	}
}

pub fn (mut log_curs LogicalCursor) move_left_buffer(mut cur_line []rune, buf BufferInterface, tabsize int) {
	if log_curs.x == 0 {
		if log_curs.y > 0 {
			log_curs.y -= 1
			cur_line = buf.line_at(log_curs.y)
			log_curs.x = cur_line.len
			log_curs.flat_index--
			log_curs.set_visual_x(cur_line, tabsize)
		}
	} else {
		log_curs.x -= 1
		log_curs.flat_index--
		log_curs.decrement_visual_x(cur_line, tabsize)
	}
}

pub fn (mut log_curs LogicalCursor) move_down_buffer(mut cur_line []rune, buf BufferInterface, tabsize int) {
	// cursor is not on the last line
	// move curse down and calculate x
	if log_curs.y < buf.line_count() - 1 {
		line := buf.line_at(log_curs.y)
		log_curs.flat_index += line.len + 1 - log_curs.x
		log_curs.y += 1
		cur_line = buf.line_at(log_curs.y)
		mut column := 0
		mut closest := 0
		for i, ch in cur_line {
			if column >= log_curs.desired_col {
				// column += if ch == `\t` { tabsize - (column % tabsize) } else { 1 }
				break
			}
			column += if ch == `\t` { tabsize - (column % tabsize) } else { 1 }
			closest = i
		}
		log_curs.x = if closest == cur_line.len - 1 && closest < log_curs.desired_col {
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

pub fn (mut log_curs LogicalCursor) move_up_buffer(mut cur_line []rune, buf BufferInterface, tabsize int) {
	log_curs.flat_index -= log_curs.x
	if log_curs.y > 0 {
		log_curs.y -= 1
		cur_line = buf.line_at(log_curs.y)
		mut column := 0
		mut closest := 0
		for i, ch in cur_line {
			if column >= log_curs.desired_col {
				break
			}
			column += if ch == `\t` { tabsize - (column % tabsize) } else { 1 }
			closest = i
		}
		log_curs.x = if closest == cur_line.len - 1 && closest < log_curs.desired_col {
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

pub fn (mut log_curs LogicalCursor) move_to_start_next_line_buffer(mut cur_line []rune, buf BufferInterface, tabsize int) {
	log_curs.move_down_buffer(mut cur_line, buf, tabsize)
	prev_x := log_curs.x
	log_curs.x = 0
	log_curs.flat_index -= prev_x
	log_curs.set_visual_x(buf.line_at(log_curs.y), tabsize)
}

pub fn (mut log_curs LogicalCursor) move_to_x_next_line_buffer(x int, mut cur_line []rune, buf BufferInterface, tabsize int) {
	// log_curs.move_down_buffer(mut cur_line, buf, tabsize)
	// prev_x := log_curs.x
	// line := buf.line_at(log_curs.y)
	// log_curs.x = line.len
	// log_curs.flat_index += line.len - prev_x
	// log_curs.set_visual_x(buf.line_at(log_curs.y), tabsize)
	log_curs.move_to_start_next_line_buffer(mut cur_line, buf, tabsize)
	log_curs.move_to_x(cur_line, x, tabsize)
}

pub fn (mut log_curs LogicalCursor) move_to_end_previous_line_buffer(mut cur_line []rune, buf BufferInterface, tabsize int) {
	log_curs.move_up_buffer(mut cur_line, buf, tabsize)
	prev_x := log_curs.x
	line := buf.line_at(log_curs.y)
	log_curs.x = line.len
	log_curs.flat_index += log_curs.x - prev_x
	log_curs.set_visual_x(buf.line_at(log_curs.y), tabsize)
}
