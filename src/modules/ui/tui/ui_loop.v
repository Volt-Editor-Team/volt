module tui

import core.controller
import util
import util.colors
import term

fn ui_loop(x voidptr) {
	mut tui_app := get_tui(x)
	mut ctx := tui_app.tui
	theme := tui_app.theme

	// get app pointer, terminal size, and clear to prep for updates
	mut app := controller.get_app(tui_app.core)
	mut view := app.viewport
	mut buf := app.buffers[app.active_buffer]
	mut command_str := util.mode_str(app.mode)
	mut text_color := colors.white
	width, height := term.get_terminal_size()
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	ctx.clear()
	// render loop
	mut wrap_offset := 0
	mut wraps := 0
	for y_index, line in buf.lines {
		runes := line.runes()
		wrap_points := view.build_wrap_points(line)
		mut line_wraps := 0
		mut char_width := 1

		for x_index, ch in runes {
			visual_x_index := buf.visual_col[y_index][x_index]
			wraps = visual_x_index / view.width
			x_pos := visual_x_index % view.width
			y_pos := y_index + wraps + wrap_offset

			mut printed := ch
			if ch == `\t` {
				printed = ` `
				char_width = buf.tabsize
			}

			if x_index == buf.logical_cursor.x && y_index == buf.logical_cursor.y {
				ctx.set_colors(theme.normal_cursor_color, theme.cursor_text_color)
				ctx.draw_text(x_pos + 1, y_pos + 1, printed.str().repeat(char_width))
				ctx.reset_colors()
			} else {
				ctx.draw_text(x_pos + 1, y_pos + 1, printed.str().repeat(char_width))
			}
			char_width = 1
		}

		// 🔑 Special case: cursor at end of line
		if buf.logical_cursor.y == y_index && buf.logical_cursor.x == runes.len {
			// find last column in this line (or 0 if empty)
			last_x := if runes.len > 0 { buf.visual_col[y_index][runes.len - 1] + 1 } else { 0 }
			last_wraps := if runes.len > 0 { last_x / view.width } else { 0 }
			cursor_x := last_x % view.width
			cursor_y := y_index + last_wraps + wrap_offset

			ctx.set_colors(theme.normal_cursor_color, theme.cursor_text_color)
			ctx.draw_text(cursor_x + 1, cursor_y + 1, ' ') // or just draw a block cursor
			ctx.reset_colors()
		}

		wrap_offset += wraps
	}

	// ctx.horizontal_separator(height - 2)
	ctx.set_bg_color(colors.deep_indigo)
	ctx.draw_line(0, height - 1, width - 1, height - 1)

	ctx.set_bg_color(util.get_command_bg_color(app.mode))
	ctx.draw_line(4, height - 1, command_str.len + 1 + 4, height - 1)
	ctx.draw_text(5, height - 1, term.bold(command_str))
	ctx.reset_bg_color()

	ctx.set_bg_color(colors.deep_indigo)
	// buf.path
	if buf.path.starts_with('Error') {
		ctx.set_color(colors.dark_red)
	} else {
		ctx.set_color(colors.white)
	}
	ctx.draw_text(command_str.len + 5 + 2, height - 1, buf.path)
	ctx.reset_color()
	ctx.draw_text(width - 5, height - 1, (buf.logical_cursor.x + 1).str() + ':' +
		(buf.logical_cursor.y + 1).str())

	ctx.reset_bg_color()

	// debugging
	// ctx.draw_text(width - 30, height - 8, 'new_col: ' + new_col.str())
	// ctx.draw_text(width - 30, height - 7, 'wrap_points: ' + wrap_points.str())
	// ctx.draw_text(width - 30, height - 6, 'wrap_offset: ' + wrap_offset.str())
	// mut line := buf.lines[logical_idx]
	// mut wrap_points := view.build_wrap_points(line)
	// num_wraps := app.viewport.get_wrapped_index(wrap_points, buf.visual_cursor.y)
	// ctx.draw_text(width - 30, height - 5, 'x: ' + buf.visual_cursor.y.str())
	// ctx.draw_text(width - 30, height - 4, 'row_wrap: ' + num_wraps.str())
	// ctx.draw_text(width - 30, height - 3, 'viewport end: ' + (app.viewport.row_offset +
	// 	app.viewport.height).str())
	// ctx.draw_text(width - 30, height - 2, 'desired col: ' + buf.logical_cursor.desired_col.str())

	if app.mode == util.Mode.command {
		buf.logical_cursor.x = app.cmd_buffer.command.len + 2
		buf.logical_cursor.y = height

		// 1. Clear the entire command line with spaces
		// width is the terminal width
		ctx.draw_text(0, buf.logical_cursor.y, ' '.repeat(width - 1))

		// 2. Draw the ':' prompt
		ctx.draw_text(0, buf.logical_cursor.y, ':')

		// 3. Draw the command buffer
		ctx.draw_text(2, buf.logical_cursor.y, app.cmd_buffer.command)

		// 4. Draw the cursor block at the right position
		// cursor_pos := app.cmd_buffer.command.len + 2
		ctx.set_bg_color(if app.mode == .normal {
			theme.normal_cursor_color
		} else {
			theme.insert_cursor_color
		})
		ctx.draw_text(buf.logical_cursor.x, buf.logical_cursor.y, ' ')
		ctx.reset_bg_color()
	}

	// update_cursor(buf.logical_cursor.x, buf.logical_cursor.y, mut ctx)
	ctx.flush()
	// ctx.paused = true
}
