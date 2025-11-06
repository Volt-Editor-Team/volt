module cursor

pub fn (mut log_curs LogicalCursor) move_to_x(x_pos int) {
	if x_pos > log_curs.x {
		log_curs.flat_index += x_pos - log_curs.x
	} else if x_pos < log_curs.x {
		log_curs.flat_index -= log_curs.x - x_pos
	}
	log_curs.x = x_pos
}
