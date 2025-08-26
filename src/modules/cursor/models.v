module cursor

import term.ui as tui

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
	x     int
	y     int
	color tui.Color = tui.Color{
		r: 128
		g: 128
		b: 128
	}
}
