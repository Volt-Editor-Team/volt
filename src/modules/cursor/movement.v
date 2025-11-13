module cursor

pub fn (mut log_curs LogicalCursor) move_to_x(cur_line []rune, x_pos int, tabsize int) {
	if x_pos > log_curs.x {
		log_curs.flat_index += x_pos - log_curs.x
	} else if x_pos < log_curs.x {
		log_curs.flat_index -= log_curs.x - x_pos
	}
	log_curs.x = x_pos
	log_curs.set_visual_x(cur_line, tabsize)
}
