module viewport

import term.ui as tui

pub struct Viewport {
pub mut:
	row_offset                 int
	col_offset                 int
	line_num_to_text_gap       int       = 3
	line_bg_color              tui.Color = tui.Color{
		r: 50
		g: 60
		b: 90
	}
	line_number_bg_color       tui.Color = tui.Color{
		r: 20
		g: 22
		b: 35
	}
	active_line_number_color   tui.Color = tui.Color{
		r: 180
		g: 180
		b: 200
	}
	inactive_line_number_color tui.Color = tui.Color{
		r: 120
		g: 130
		b: 150
	}
	height                     int
	width                      int
pub:
	margin int
}
