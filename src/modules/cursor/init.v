module cursor

import buffer { Buffer }

pub fn (mut vis_curs VisualCursor) update(buf Buffer, mut log_curs LogicalCursor) {
	vis_curs.x, vis_curs.y = buf.get_visual_coords(log_curs.x, log_curs.y)
}

pub fn (mut log_curs LogicalCursor) update_desired_col(col int, viewport_width int) {
	log_curs.desired_col = (col + viewport_width) % viewport_width
}

pub fn (mut log_curs LogicalCursor) move_right_buffer(buf Buffer) {
	line := buf.lines[log_curs.y]

	if log_curs.x < line.len {
		log_curs.x++
	} else if log_curs.y < buf.lines.len - 1 {
		log_curs.x = 0
		log_curs.y++
	}
}

pub fn (mut log_curs LogicalCursor) move_left_buffer(buf Buffer) {
	if log_curs.x == 0 {
		if log_curs.y > 0 {
			log_curs.y -= 1
			log_curs.x = buf.lines[log_curs.y].len
		}
	} else {
		log_curs.x -= 1
	}
}

pub fn (mut log_curs LogicalCursor) move_down_buffer(buf Buffer) {
	if log_curs.y < buf.lines.len - 1 {
		log_curs.y += 1
		log_curs.x = buf.logical_x(log_curs.y, log_curs.desired_col)
	} else {
		log_curs.x = buf.lines[log_curs.y].len
	}
}

pub fn (mut log_curs LogicalCursor) move_up_buffer(buf Buffer) {
	if log_curs.y > 0 {
		log_curs.y -= 1
		log_curs.x = buf.logical_x(log_curs.y, log_curs.desired_col)
	} else if log_curs.y == 0 {
		log_curs.x = 0
	}
}

pub fn (mut log_curs LogicalCursor) move_to_start_next_line_buffer(buf Buffer) {
	log_curs.move_down_buffer(buf)
	log_curs.x = 0
}

pub fn (mut log_curs LogicalCursor) move_to_end_previous_line_buffer(buf Buffer) {
	log_curs.move_up_buffer(buf)
	log_curs.x = buf.lines[log_curs.y].len
}

pub fn (mut log_curs LogicalCursor) move_to_x(buf Buffer, x_pos int) {
	log_curs.x = x_pos
}
