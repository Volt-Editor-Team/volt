module ui

import controller
import util
import util.constants
import term
import math

fn update_cursor(mut app controller.App) {
	x_pos := app.logical_cursor.x + 1
	y_pos := app.logical_cursor.y + 1
	app.tui.set_cursor_position(x_pos, y_pos)
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
		mut runes := line.runes()
		runes << ` `
		for j, ch in runes {
			// draw line number
			line_num := i + 1
			if app.logical_cursor.y == i {
				app.tui.set_color(app.viewport.active_line_number_color)
			} else {
				app.tui.set_color(app.viewport.inactive_line_number_color)
			}
			app.tui.draw_text(app.viewport.col_offset, line_num, line_num.str())
			app.tui.reset_color()
			col_start := app.viewport.col_offset + app.viewport.line_num_to_text_gap

			// visual column from cache
			mut col := if j < visual_line.len {
				visual_line[j]
			} else {
				if visual_line.len > 0 { visual_line.last() + 1 } else { 0 }
			}
			mut printed := ch
			mut char_width := 1
			if ch == `\t` {
				printed = ` `
				char_width = app.buffer.tabsize
			}

			// draw text
			for k in 0 .. char_width {
				if col == app.visual_cursor.x && i == app.visual_cursor.y {
					app.tui.set_bg_color(app.visual_cursor.color)
					app.tui.draw_text(col_start + col + k + 1, i + 1, printed.str())
					app.tui.reset_bg_color()
				} else {
					app.tui.draw_text(col_start + col + 1, i + 1, ch.str())
				}
			}
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
	app.tui.draw_text(width - 5, height - 1, (app.logical_cursor.x + 1).str() + ':' +
		(app.logical_cursor.y + 1).str())

	app.tui.reset_bg_color()

	// debugging
	app.tui.draw_text(width - 30, height - 5, 'x: ' + app.logical_cursor.x.str())
	app.tui.draw_text(width - 30, height - 4, 'viewport start: ' + app.viewport.row_offset.str())
	app.tui.draw_text(width - 30, height - 3, 'viewport end: ' + (app.viewport.row_offset +
		app.viewport.height).str())
	app.tui.draw_text(width - 30, height - 2, 'desired col: ' + app.logical_cursor.desired_col.str())

	if app.mode == util.Mode.command {
		app.logical_cursor.x = app.cmd_buffer.command.len + 1
		app.logical_cursor.y = height

		cursor_pos := app.cmd_buffer.command.len + 2

		// app.visual_cursor.update(app.buffer, mut app.logical_cursor)
		app.tui.draw_text(0, app.logical_cursor.y, ':')
		app.tui.draw_text(2, app.logical_cursor.y, app.cmd_buffer.command)

		app.tui.set_bg_color(app.visual_cursor.color)
		app.tui.draw_text(cursor_pos, app.logical_cursor.y, ' ')
		app.tui.reset_bg_color()

		// app.tui.flush()
	}
	app.tui.reset()

	update_cursor(mut app)
}
