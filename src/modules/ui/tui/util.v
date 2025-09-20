module tui

import term
import term.ui
import util { Mode }

pub fn get_terminal_size() (int, int) {
	return term.get_terminal_size()
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
	mut bg_color := theme.active_line_bg_color
	if mode == .normal || mode == .command {
		bg_color = theme.normal_cursor_color
	} else if (ctx.frame_count / 15) % 2 == 0 {
		// use frame_count to similute blinking cursor
		// every 0.5 seconds (30 * 0.5)
		bg_color = theme.insert_cursor_color
	}

	mut fg_color := theme.normal_text_color
	if mode == .normal || mode == .command {
		fg_color = theme.cursor_text_color
	} else if (ctx.frame_count / 15) % 2 == 0 {
		fg_color = theme.cursor_text_color
	}

	return bg_color, fg_color
}
