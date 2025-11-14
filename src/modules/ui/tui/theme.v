module tui

import ui
import term.ui as t
import util.colors { hex_to_tui_color }

struct TuiTheme {
mut:
	normal_text_color          t.Color
	normal_cursor_color        t.Color
	insert_cursor_color        t.Color
	cursor_text_color          t.Color
	active_line_bg_color       t.Color
	active_line_number_color   t.Color
	inactive_line_number_color t.Color
	background_color           t.Color
	command_bar_color          t.Color
	tab_bar_color              t.Color
	active_tab_color           t.Color
}

fn TuiTheme.new(theme ui.ColorScheme) TuiTheme {
	return TuiTheme{
		normal_text_color:          hex_to_tui_color(theme.normal_text_color) or { colors.white }
		normal_cursor_color:        hex_to_tui_color(theme.normal_cursor_color) or {
			colors.default_normal_cursor_color
		}
		insert_cursor_color:        hex_to_tui_color(theme.insert_cursor_color) or {
			colors.default_insert_cursor_color
		}
		cursor_text_color:          hex_to_tui_color(theme.cursor_text_color) or {
			colors.default_cursor_text_color
		}
		active_line_bg_color:       hex_to_tui_color(theme.active_line_bg_color) or {
			colors.default_active_line_bg_color
		}
		active_line_number_color:   hex_to_tui_color(theme.active_line_number_color) or {
			colors.default_active_line_number_color
		}
		inactive_line_number_color: hex_to_tui_color(theme.inactive_line_number_color) or {
			colors.default_inactive_line_number_color
		}
		background_color:           hex_to_tui_color(theme.background_color) or {
			colors.google_dark_grey
		}
		command_bar_color:          hex_to_tui_color(theme.command_bar_color) or {
			colors.deep_indigo_2
		}
		tab_bar_color:              hex_to_tui_color(theme.tab_bar_color) or {
			colors.deep_indigo_2
		}
		active_tab_color:           hex_to_tui_color(theme.active_tab_color) or { colors.amber_2 }
	}
}
