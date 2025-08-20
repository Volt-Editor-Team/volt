module cursor

pub struct Cursor {
pub mut:
	// cursor coordinates
	x           int
	y           int
	visual_x    int
	desired_col int
}
