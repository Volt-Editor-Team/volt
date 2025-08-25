module cursor

import term.ui as tui

pub struct Cursor {
pub mut:
	// cursor coordinates
	x           int
	y           int
	visual_x    int
	desired_col int
	color       tui.Color = tui.Color{
		r: 255
		g: 255
		b: 255
	}
}
