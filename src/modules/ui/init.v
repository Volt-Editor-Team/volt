module ui

pub enum Ui {
	tui
	gui
}

pub struct ColorScheme {
pub mut:
	cursor_color               string
	cursor_text_color          string // the text color under the cursor
	active_line_bg_color       string
	active_line_number_color   string
	inactive_line_number_color string
}
