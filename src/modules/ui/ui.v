module ui

import controller
import util
import util.constants
import term
import math

fn update_cursor(mut app controller.App) {
	match app.mode {
		.command {
			app.tui.set_cursor_position(app.cursor.x + 1, app.cursor.y + 1)
		}
		else {
			app.tui.set_cursor_position(app.cursor.visual_x + 1, app.cursor.y + 1 - app.viewport.row_offset)
		}
	}
	app.tui.flush()
}

fn frame(x voidptr) {
	// get app pointer, terminal size, and clear to prep for updates
	mut app := controller.get_app(x)
	width, height := term.get_terminal_size()
	app.tui.clear()

	// initialize variables to simplify loop
	start_row := app.viewport.row_offset
	end_row := math.min(app.buffer.lines.len, app.viewport.row_offset + app.viewport.height)

	// render all visual lines
	// render all tabs as 4 spaces
	for i, line in app.buffer.lines[start_row..end_row] {
		visual_line := app.buffer.visual_col[start_row + i]
		for j, ch in line.runes() {
			mut col := visual_line[j] // visual column from cache
			app.tui.draw_text(col + 1, i + 1, ch.str())
		}
	}

	// app.tui.horizontal_separator(height - 2)
	app.tui.set_bg_color(constants.deep_indigo)
	app.tui.draw_line(0, height - 1, width - 1, height - 1)

	command_str := util.mode_str(app.mode)

	app.tui.set_bg_color(util.get_command_bg_color(app.mode))

	app.tui.draw_line(4, height - 1, command_str.len + 1 + 4, height - 1)

	app.tui.draw_text(5, height - 1, term.bold(command_str))

	app.tui.set_bg_color(constants.deep_indigo)

	app.tui.draw_text(command_str.len + 5 + 2, height - 1, './src/main.v')
	app.tui.draw_text(width - 5, height - 1, app.cursor.x.str() + ':' + app.cursor.y.str())

	app.tui.reset_bg_color()

	// debugging
	app.tui.draw_text(width - 30, height - 5, 'x: ' + app.cursor.x.str())
	app.tui.draw_text(width - 30, height - 4, 'viewport start: ' + app.viewport.row_offset.str())
	app.tui.draw_text(width - 30, height - 3, 'viewport end: ' + (app.viewport.row_offset +
		app.viewport.height).str())
	app.tui.draw_text(width - 30, height - 2, 'desired col: ' + app.cursor.desired_col.str())
	if app.mode == util.Mode.command {
		app.cursor.x = app.cmd_buffer.len + 1
		app.cursor.y = height

		// app.tui.set_cursor_position(app.cmd_buffer.len + 1, height)
		app.tui.draw_text(0, app.cursor.y, ':')
		app.tui.draw_text(2, app.cursor.y, app.cmd_buffer)

		// app.tui.flush()
	}

	app.tui.reset()

	update_cursor(mut app)
}
