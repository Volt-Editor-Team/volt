module cursor

import buffer.common { BufferInterface }

pub fn (mut log_curs LogicalCursor) move_right_buffer(buf BufferInterface) {
	line_len := buf.line_at(log_curs.y).runes().len

	if log_curs.x < line_len {
		log_curs.x++
	} else if log_curs.y < buf.line_count() - 1 {
		log_curs.x = 0
		log_curs.y++
	}
	log_curs.flat_index++
}

pub fn (mut log_curs LogicalCursor) move_left_buffer(buf BufferInterface) {
	if log_curs.x == 0 {
		if log_curs.y > 0 {
			log_curs.y -= 1
			log_curs.x = buf.line_at(log_curs.y).runes().len
		}
	} else {
		log_curs.x -= 1
	}
	log_curs.flat_index--
}

pub fn (mut log_curs LogicalCursor) move_down_buffer(buf BufferInterface, tabsize int) {
	// cursor is not on the last line
	// move curse down and calculate x
	if log_curs.y < buf.line_count() - 1 {
		log_curs.flat_index += buf.line_at(log_curs.y).runes().len + 1 - log_curs.x
		log_curs.y += 1
		// log_curs.x = logical_x_fn(log_curs.y, log_curs.desired_col)
		line := buf.line_at(log_curs.y).runes()
		mut column := 0
		mut closest := 0
		for i, ch in line {
			if column >= log_curs.desired_col {
				column += if ch == `\t` { tabsize - (column % tabsize) } else { 1 }
				break
			}
			column += if ch == `\t` { tabsize - (column % tabsize) } else { 1 }
			closest = i
		}
		log_curs.x = if closest == line.len - 1 && closest + column < log_curs.desired_col {
			closest + 1
		} else {
			closest
		}
		log_curs.flat_index += log_curs.x
	} else {
		// cursor is on the last line
		// move cursor the end
		log_curs.flat_index += buf.line_at(log_curs.y).runes().len - log_curs.x
		log_curs.x = buf.line_at(log_curs.y).runes().len
	}
}

pub fn (mut log_curs LogicalCursor) move_up_buffer(buf BufferInterface, tabsize int) {
	log_curs.flat_index -= log_curs.x
	if log_curs.y > 0 {
		log_curs.y -= 1
		line := buf.line_at(log_curs.y).runes()
		mut column := 0
		mut closest := 0
		for i, ch in line {
			if column >= log_curs.desired_col {
				break
			}
			column += if ch == `\t` { tabsize - (column % tabsize) } else { 1 }
			closest = i
		}
		log_curs.x = if closest == line.len - 1 && closest < log_curs.desired_col {
			closest + 1
		} else {
			closest
		}
		log_curs.flat_index -= line.len + 1 - log_curs.x
	} else if log_curs.y == 0 {
		log_curs.x = 0
	}
}

pub fn (mut log_curs LogicalCursor) move_to_start_next_line_buffer(buf BufferInterface, tabsize int) {
	log_curs.move_down_buffer(buf, tabsize)
	prev_x := log_curs.x
	log_curs.x = 0
	log_curs.flat_index -= prev_x
}

pub fn (mut log_curs LogicalCursor) move_to_end_previous_line_buffer(buf BufferInterface, tabsize int) {
	log_curs.move_up_buffer(buf, tabsize)
	prev_x := log_curs.x
	log_curs.x = buf.line_at(log_curs.y).runes().len
	log_curs.flat_index += log_curs.x - prev_x
}
