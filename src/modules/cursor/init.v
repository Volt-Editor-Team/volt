module cursor

pub struct LogicalCursor {
pub mut:
	// cursor coordinates
	x           int
	y           int
	visual_x    int
	flat_index  int
	desired_col int = 1
}

// pub struct VisualCursor {
// pub mut:
// 	// cursor coordinates
// 	x int
// 	y int
// }
