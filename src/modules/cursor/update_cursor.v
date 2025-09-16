module cursor

import buffer { Buffer }

pub fn (mut vis_curs VisualCursor) update(buf Buffer, mut log_curs LogicalCursor) {
	vis_curs.x, vis_curs.y = buf.get_visual_coords(log_curs.x, log_curs.y)
}

pub fn (mut log_curs LogicalCursor) update_desired_col(col int, viewport_width int) {
	log_curs.desired_col = (col + viewport_width) % viewport_width
}
