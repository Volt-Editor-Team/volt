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
	x          int
	y          int
	color      tui.Color = tui.Color{
		r: 120
		g: 150
		b: 200
	}
	text_color tui.Color = tui.Color{
		r: 20
		g: 30
		b: 50
	}
}
