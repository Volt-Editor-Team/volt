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

pub fn (mut log_curs LogicalCursor) move_down_buffer(lines []string, logical_x_fn fn (line_index int, visual_x int) int) {
	if log_curs.y < lines.len - 1 {
		log_curs.y += 1
		log_curs.x = logical_x_fn(log_curs.y, log_curs.desired_col)
	} else {
		log_curs.x = lines[log_curs.y].len
	}
}

pub fn (mut log_curs LogicalCursor) move_up_buffer(logical_x_fn fn (line_index int, visual_x int) int) {
	if log_curs.y > 0 {
		log_curs.y -= 1
		log_curs.x = logical_x_fn(log_curs.y, log_curs.desired_col)
	} else if log_curs.y == 0 {
		log_curs.x = 0
	}
}

pub fn (mut log_curs LogicalCursor) move_to_start_next_line_buffer(lines []string, logical_x_fn fn (line_index int, visual_x int) int) {
	log_curs.move_down_buffer(lines, logical_x_fn)
	log_curs.x = 0
}

pub fn (mut log_curs LogicalCursor) move_to_end_previous_line_buffer(lines []string, logical_x_fn fn (line_index int, visual_x int) int) {
	log_curs.move_up_buffer(logical_x_fn)
	log_curs.x = lines[log_curs.y].len
}
