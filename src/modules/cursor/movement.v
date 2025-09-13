module cursor

pub fn (mut log_curs LogicalCursor) move_to_x(x_pos int) {
	log_curs.x = x_pos
}
