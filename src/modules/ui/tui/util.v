module tui

import term
import term.ui

pub fn get_terminal_size() (int, int) {
	return term.get_terminal_size()
}

fn update_cursor(x int, y int, mut ctx ui.Context) {
	x_pos := x + 1
	y_pos := y + 1
	ctx.set_cursor_position(x_pos, y_pos)
}
