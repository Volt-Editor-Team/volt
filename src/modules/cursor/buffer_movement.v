module cursor

pub fn (mut log_curs LogicalCursor) move_right_buffer(lines []string) {
	line := lines[log_curs.y]

	if log_curs.x < line.len {
		log_curs.x++
	} else if log_curs.y < lines.len - 1 {
		log_curs.x = 0
		log_curs.y++
	}
}

pub fn (mut log_curs LogicalCursor) move_left_buffer(lines []string) {
	if log_curs.x == 0 {
		if log_curs.y > 0 {
			log_curs.y -= 1
			log_curs.x = lines[log_curs.y].len
		}
	} else {
		log_curs.x -= 1
	}
}

pub fn (mut log_curs LogicalCursor) move_down_buffer(lines []string, tabsize int) {
	// cursor is not on the last line
	// move curse down and calculate x
	if log_curs.y < lines.len - 1 {
		log_curs.y += 1
		// log_curs.x = logical_x_fn(log_curs.y, log_curs.desired_col)
		line := lines[log_curs.y].runes()
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
	} else {
		// cursor is on the last line
		// move cursor the end
		log_curs.x = lines[log_curs.y].len
	}
}

pub fn (mut log_curs LogicalCursor) move_up_buffer(lines []string, tabsize int) {
	if log_curs.y > 0 {
		log_curs.y -= 1
		line := lines[log_curs.y].runes()
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
	} else if log_curs.y == 0 {
		log_curs.x = 0
	}
}

pub fn (mut log_curs LogicalCursor) move_to_start_next_line_buffer(lines []string, tabsize int) {
	log_curs.move_down_buffer(lines, tabsize)
	log_curs.x = 0
}

pub fn (mut log_curs LogicalCursor) move_to_end_previous_line_buffer(lines []string, tabsize int) {
	log_curs.move_up_buffer(lines, tabsize)
	log_curs.x = lines[log_curs.y].len
}
