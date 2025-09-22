module ui

pub enum Ui {
	tui
	gui
}

pub struct ColorScheme {
pub mut:
	normal_text_color          string
	normal_cursor_color        string
	insert_cursor_color        string
	cursor_text_color          string // the text color under the cursor
	active_line_bg_color       string
	active_line_number_color   string
	inactive_line_number_color string
	background_color           string
	command_bar_color          string
	tab_bar_color              string
	active_tab_color           string
}
