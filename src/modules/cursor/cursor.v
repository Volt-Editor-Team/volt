module cursor

import buffer { Buffer }

pub fn (mut curs Cursor) move_right_buffer(buf Buffer) {
	line := buf.lines[curs.y]

	if curs.x < line.len {
		curs.x++
	} else if curs.y < buf.lines.len - 1 {
		curs.x = 0
		curs.y++
	}
	curs.visual_x = buf.visual_x(curs.y, curs.x)
	curs.desired_col = curs.visual_x
}

pub fn (mut curs Cursor) move_left_buffer(buf Buffer) {
	if curs.x == 0 {
		if curs.y > 0 {
			curs.y -= 1
			curs.x = buf.lines[curs.y].len
		}
	} else {
		curs.x -= 1
	}
	curs.visual_x = buf.visual_x(curs.y, curs.x)
	curs.desired_col = curs.visual_x
}

pub fn (mut curs Cursor) move_down_buffer(buf Buffer) {
	if curs.y < buf.lines.len - 1 {
		curs.y += 1
		curs.x = buf.logical_x(curs.y, curs.desired_col)
	} else {
		curs.x = buf.lines[curs.y].len
	}
	curs.visual_x = buf.visual_x(curs.y, curs.x)
}

pub fn (mut curs Cursor) move_up_buffer(buf Buffer) {
	if curs.y > 0 {
		curs.y -= 1
		curs.x = buf.logical_x(curs.y, curs.desired_col)
	} else if curs.y == 0 {
		curs.x = 0
	}
	curs.visual_x = buf.visual_x(curs.y, curs.x)
}

pub fn (mut curs Cursor) move_to_start_next_line_buffer(buf Buffer) {
	curs.x = 0
	curs.visual_x = 0
	curs.desired_col = curs.visual_x
	curs.move_down_buffer(buf)
}

pub fn (mut curs Cursor) move_to_end_previous_line_buffer(buf Buffer) {
	curs.move_up_buffer(buf)
	curs.x = buf.lines[curs.y].len
	curs.visual_x = buf.lines[curs.y].len
	curs.desired_col = curs.visual_x
}

pub fn (mut curs Cursor) move_to_x(buf Buffer, x_pos int) {
	curs.x = x_pos
	curs.visual_x = buf.visual_x(curs.y, curs.x)
	curs.desired_col = curs.visual_x
}
