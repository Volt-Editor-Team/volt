module cursor

// depreciated
// import buffer

// pub fn (mut vis_curs VisualCursor) update(get_visual_coords fn (int, int) (int, int), mut log_curs LogicalCursor) {
// 	vis_curs.x, vis_curs.y = get_visual_coords(log_curs.x, log_curs.y)
// }

pub fn (mut log_curs LogicalCursor) update_desired_col(viewport_width int) {
	log_curs.desired_col = (log_curs.visual_x + viewport_width) % viewport_width
}
