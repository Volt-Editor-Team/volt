module viewport

import term.ui as tui

pub struct Viewport {
pub mut:
	row_offset                 int
	col_offset                 int
	line_num_to_text_gap       int       = 3
	line_bg_color              tui.Color = tui.Color{
		r: 50
		g: 50
		b: 50
	}
	active_line_number_color   tui.Color = tui.Color{
		r: 255
		g: 255
		b: 255
	}
	inactive_line_number_color tui.Color = tui.Color{
		r: 50
		g: 50
		b: 50
	}
pub:
	height int
	width  int
	margin int
}
