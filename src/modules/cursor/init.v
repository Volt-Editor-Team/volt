module cursor

pub struct LogicalCursor {
pub mut:
	// cursor coordinates
	x           int
	y           int
	desired_col int
}

pub struct VisualCursor {
pub mut:
	// cursor coordinates
	x int
	y int
}
