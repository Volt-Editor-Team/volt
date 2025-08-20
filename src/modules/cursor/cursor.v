module cursor

import buffer { Buffer }

pub fn (mut curs Cursor) move_right(buf Buffer) {
	line := buf.lines[curs.y]

	if curs.x < line.len {
		curs.x++
	} else if curs.y < buf.lines.len - 1 {
		curs.x = 0
		curs.y++
	}
}

pub fn (mut curs Cursor) move_left(buf Buffer) {
	if curs.x == 0 {
		if curs.y > 0 {
			curs.y -= 1
			curs.x = buf.lines[curs.y].len
		}
	} else {
		curs.x -= 1
	}
}
