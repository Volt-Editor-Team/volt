module cursor

import util

pub fn (mut log_curs LogicalCursor) set_visual_x(line []rune, tabsize int) {
	log_curs.visual_x = util.expand_line_to(line, log_curs.x, tabsize)
	if log_curs.x >= line.len {
		log_curs.visual_x++
	}
}

pub fn (mut log_curs LogicalCursor) increment_visual_x(line []rune, tabsize int) {
	if log_curs.x >= line.len {
		log_curs.visual_x++
	} else {
		log_curs.visual_x += util.get_char_width(line[log_curs.x], tabsize)
	}
}

pub fn (mut log_curs LogicalCursor) decrement_visual_x(line []rune, tabsize int) {
	if log_curs.x >= line.len {
		log_curs.visual_x--
	} else {
		log_curs.visual_x -= util.get_char_width(line[log_curs.x], tabsize)
	}
}
