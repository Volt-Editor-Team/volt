module tui

import term
import term.ui
import util { Mode, PersistantMode }
import util.colors
import util.constants
import fs
import os

pub fn get_terminal_size() (int, int) {
	return term.get_terminal_size()
}

fn (mut ctx TuiContext) draw_background(start_x int, start_y int, end_x int, end_y int, theme TuiTheme) {
	ctx.set_bg_color(theme.background_color)
	ctx.draw_rect(start_x, start_y, end_x, end_y)
	ctx.reset_bg_color()
}

fn (mut ctx TuiContext) draw_tabs(buffer_names []string, active_buffer int, width int, theme TuiTheme) {
	ctx.set_bg_color(theme.tab_bar_color)
	ctx.draw_line(0, 1, width - 1, 1)
	ctx.reset_colors()
	mut tab_pos := 1
	for i, name in buffer_names {
		if i == active_buffer {
			ctx.set_colors(theme.active_tab_color, theme.cursor_text_color)
			ctx.draw_text(tab_pos + 1, 1, term.bold(name))
			ctx.reset_colors()
		} else {
			ctx.set_bg_color(theme.tab_bar_color)
			ctx.draw_text(tab_pos + 1, 1, name)
			ctx.reset_colors()
		}
		tab_pos += name.len
	}
}

fn (mut ctx TuiContext) get_gutter_label_and_colors(cur_path string, cur_line []rune, y_index int, line_count int, p_mode PersistantMode, theme TuiTheme) (string, ui.Color, ui.Color, ui.Color) {
	mut line_num_label := term.bold(' '.repeat(line_count.str().len - (y_index + 1).str().len) +
		(y_index + 1).str())
	mut line_num_inactive_color := theme.inactive_line_number_color
	mut line_num_active_color := theme.active_line_number_color
	mut text_color := colors.white

	if p_mode == .directory {
		line := cur_line.string()
		if fs.is_dir(cur_path + line) {
			line_num_label = ' '.repeat(line_count.str().len)
			text_color = colors.royal_blue
		} else {
			file_ext := os.file_ext(line)
			if file_ext in constants.ext_icons {
				filetype := constants.ext_icons[file_ext]
				line_num_inactive_color = colors.hex_to_tui_color(filetype.color) or {
					colors.white
				}
				line_num_active_color = line_num_inactive_color
				line_num_label = ' '.repeat(line_count.str().len - filetype.icon.len) +
					filetype.icon
			} else {
				line_num_label = ' '.repeat(line_count.str().len)
			}
		}
	}

	return line_num_label, text_color, line_num_active_color, line_num_inactive_color
}

fn update_cursor(x int, y int, mut ctx ui.Context) {
	x_pos := x + 1
	y_pos := y + 1
	ctx.set_cursor_position(x_pos, y_pos)
}

fn (mut ctx TuiContext) set_colors(bg_color ui.Color, fg_color ui.Color) {
	ctx.set_bg_color(bg_color)
	ctx.set_color(fg_color)
}

fn (mut ctx TuiContext) reset_colors() {
	ctx.reset_bg_color()
	ctx.reset_color()
}

fn (mut ctx TuiContext) draw_text_with_colors(bg_color ui.Color, fg_color ui.Color, x_pos int, y_pos int, text string) {
	ctx.set_colors(bg_color, fg_color)
	ctx.draw_text(x_pos, y_pos, text)
	ctx.reset_colors()
}

fn (mut ctx TuiContext) get_cursor_colors(mode Mode, theme TuiTheme) (ui.Color, ui.Color) {
	mut bg_color := theme.normal_cursor_color
	mut fg_color := theme.cursor_text_color
	// if false {
	// 	// rough blinking cursor implementation
	// 	if mode != .normal && mode != .command {
	// 		bg_color = theme.active_line_bg_color
	// 		fg_color = theme.normal_text_color
	// 		if (ctx.frame_count / 10) % 2 == 0 {
	// 			// use frame_count to similute blinking cursor
	// 			// every 0.5 seconds (30 * 0.5)
	// 			bg_color = theme.insert_cursor_color
	// 			fg_color = theme.cursor_text_color
	// 		}
	// 	}

	// 	return bg_color, fg_color
	// } else {
	// default

	if mode == .insert {
		bg_color = theme.insert_cursor_color
		fg_color = theme.cursor_text_color
	}
	return bg_color, fg_color
	// }
}
