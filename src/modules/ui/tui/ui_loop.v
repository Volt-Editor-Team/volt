module tui

import core.controller
import util
import util.colors
import term
// import math

fn ui_loop(x voidptr) {
	mut tui_app := get_tui(x)
	mut ctx := tui_app.tui
	// get app pointer, terminal size, and clear to prep for updates
	mut app := controller.get_app(tui_app.core)
	mut view := app.viewport
	mut buf := app.buffers[app.active_buffer]
	theme := tui_app.theme
	width, height := term.get_terminal_size()
	ctx.clear()

	y_pos := app.buffers[app.active_buffer].visual_cursor.y
	x_pos := app.buffers[app.active_buffer].visual_cursor.x
	col_start := app.viewport.col_offset + app.viewport.line_num_to_text_gap

	mut actual_line_idx := 0 // line we’re drawing on screen
	mut logical_idx := view.row_offset // start at first visible buffer line

	for logical_idx < buf.lines.len && actual_line_idx < view.height {
		line := buf.lines[logical_idx]
		line_num := logical_idx + 1
		alignment_spaces := ' '.repeat(buf.lines.len.str().len - line_num.str().len)

		mut wrap_points := view.build_wrap_points(line)
		if wrap_points.len == 0 {
			wrap_points = [0] // guarantee empty lines draw
		}

		mut runes := line.runes()
		runes << ` ` // ensure empty lines render

		// iterate per wrap row
		for wrap_row in 0 .. wrap_points.len {
			if actual_line_idx >= view.height {
				break
			}

			// draw line number only on first wrap row
			if logical_idx == y_pos {
				ctx.set_bg_color(theme.active_line_bg_color)
				ctx.set_color(theme.active_line_number_color)
				ctx.draw_line(0, actual_line_idx + 1, width - 1, actual_line_idx + 1)
				ctx.reset_bg_color()
				ctx.reset_color()
			}
			if wrap_row == 0 {
				if logical_idx == y_pos {
					ctx.set_bg_color(theme.active_line_bg_color)
					ctx.set_color(theme.active_line_number_color)
					ctx.draw_line(0, actual_line_idx + 1, width - 1, actual_line_idx + 1)
					ctx.draw_text(view.col_offset, actual_line_idx + 1, alignment_spaces +
						line_num.str())
					ctx.reset_bg_color()
					ctx.reset_color()
				} else {
					ctx.set_color(theme.inactive_line_number_color)
					ctx.draw_text(view.col_offset, actual_line_idx + 1, alignment_spaces +
						line_num.str())
					ctx.reset_color()
				}
			}

			// draw characters for this wrap row
			start := wrap_points[wrap_row]
			end := if wrap_row + 1 < wrap_points.len { wrap_points[wrap_row + 1] } else { runes.len }
			mut segment := runes[start..end].clone()

			segment << ` `

			mut visual_col := 0

			for _, ch in segment {
				mut printed := ch
				mut char_width := 1
				if ch == `\t` {
					printed = ` `
					char_width = buf.tabsize - (visual_col % buf.tabsize)
				}

				let_draw_y := actual_line_idx + 1
				let_draw_x := col_start + visual_col + view.line_num_to_text_gap

				for k in 0 .. char_width {
					if visual_col == x_pos && logical_idx == y_pos {
						ctx.set_bg_color(theme.cursor_color)
						ctx.set_color(theme.cursor_text_color)
						ctx.draw_text(let_draw_x + k, let_draw_y, printed.str())
						ctx.reset_bg_color()
						ctx.reset_color()
					} else if logical_idx == y_pos {
						ctx.set_bg_color(theme.active_line_bg_color)
						ctx.draw_text(let_draw_x + k, let_draw_y, printed.str())
						ctx.reset_bg_color()
					} else {
						ctx.draw_text(let_draw_x + k, let_draw_y, printed.str())
					}
				}
				visual_col += char_width
			}

			// increment screen row per wrap
			actual_line_idx++
		}

		// move to next buffer line
		logical_idx++
	}

	// ctx.horizontal_separator(height - 2)
	ctx.set_bg_color(colors.deep_indigo)
	ctx.draw_line(0, height - 1, width - 1, height - 1)

	command_str := util.mode_str(app.mode)

	ctx.set_bg_color(util.get_command_bg_color(app.mode))

	ctx.draw_line(4, height - 1, command_str.len + 1 + 4, height - 1)

	ctx.draw_text(5, height - 1, term.bold(command_str))

	ctx.set_bg_color(colors.deep_indigo)

	ctx.draw_text(command_str.len + 5 + 2, height - 1, './src/main.v')
	ctx.draw_text(width - 5, height - 1, (app.buffers[app.active_buffer].logical_cursor.x +
		1).str() + ':' + (app.buffers[app.active_buffer].logical_cursor.y + 1).str())

	ctx.reset_bg_color()

	// debugging
	// ctx.draw_text(width - 30, height - 8, 'new_col: ' + new_col.str())
	// ctx.draw_text(width - 30, height - 7, 'wrap_points: ' + wrap_points.str())
	// ctx.draw_text(width - 30, height - 6, 'wrap_offset: ' + wrap_offset.str())
	// ctx.draw_text(width - 30, height - 5, 'x: ' + app.buffers[app.active_buffer].logical_cursor.x.str())
	// ctx.draw_text(width - 30, height - 4, 'viewport start: ' + app.viewport.row_offset.str())
	// ctx.draw_text(width - 30, height - 3, 'viewport end: ' + (app.viewport.row_offset +
	// 	app.viewport.height).str())
	// ctx.draw_text(width - 30, height - 2, 'desired col: ' + app.buffers[app.active_buffer].logical_cursor.desired_col.str())

	if app.mode == util.Mode.command {
		app.buffers[app.active_buffer].logical_cursor.x = app.cmd_buffer.command.len + 2
		app.buffers[app.active_buffer].logical_cursor.y = height

		// 1. Clear the entire command line with spaces
		// width is the terminal width
		ctx.draw_text(0, app.buffers[app.active_buffer].logical_cursor.y, ' '.repeat(width - 1))

		// 2. Draw the ':' prompt
		ctx.draw_text(0, app.buffers[app.active_buffer].logical_cursor.y, ':')

		// 3. Draw the command buffer
		ctx.draw_text(2, app.buffers[app.active_buffer].logical_cursor.y, app.cmd_buffer.command)

		// 4. Draw the cursor block at the right position
		// cursor_pos := app.cmd_buffer.command.len + 2
		ctx.set_bg_color(theme.cursor_color)
		ctx.draw_text(app.buffers[app.active_buffer].logical_cursor.x, app.buffers[app.active_buffer].logical_cursor.y,
			' ')
		ctx.reset_bg_color()
	}

	ctx.flush()
	// 	update_cursor(app.buffers[app.active_buffer].logical_cursor.x, app.buffers[app.active_buffer].logical_cursor.y, mut ctx)
}
