module tui

import core.controller
import util
import util.colors
import util.constants
import term
import math
import fs
import os

fn ui_loop(x voidptr) {
	mut tui_app := get_tui(x)
	mut ctx := tui_app.tui
	theme := tui_app.theme

	// get app pointer, terminal size, and clear to prep for updates
	mut app := controller.get_app(tui_app.core)
	mut view := &app.viewport
	mut buf := app.buffers[app.active_buffer]
	mut command_str := util.mode_str(buf.mode, buf.p_mode)
	multiple_buffers := app.buffers.len > 1
	buffer_gap := int(multiple_buffers)
	// mut text_color := colors.white
	width, height := term.get_terminal_size()

	// --- draw background ---
	ctx.set_bg_color(theme.background_color)
	ctx.draw_rect(1, 1, width, height)
	ctx.reset_bg_color()

	// --- draw tabs for multiple buffers ---
	if multiple_buffers {
		ctx.set_bg_color(theme.tab_bar_color)
		ctx.draw_line(0, 1, width - 1, 1)
		ctx.reset_colors()
		buffer_names := []string{len: app.buffers.len, init: ' ' + app.buffers[index].label + ' '}
		mut tab_pos := 1
		for i, name in buffer_names {
			if i == app.active_buffer {
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

	start_row := buf.row_offset
	mut end_row := start_row
	if buf.p_mode != .fuzzy {
		end_row = math.min(buf.buffer.line_count(), buf.row_offset + view.height) // final line of buffer to render (+1 for inclusivity)
	} else {
		end_row = math.min(buf.temp_data.len, buf.row_offset + view.height) // final line of buffer to render (+1 for inclusivity)
	}

	// --- render text ---
	if buf.p_mode != .fuzzy {
		// render loop
		mut wrap_offset := 0
		mut wraps := 0
		// render_lines: for i, line in buf.lines[start_row..end_row] {
		render_lines: for i in 0 .. end_row - start_row {
			// i is the row index of the actual renders screen
			// y_index is the position in the buffer
			y_index := start_row + i
			line := buf.buffer.line_at(y_index)

			// values necessary for rendering aligned line numbers
			mut line_num_label := term.bold((y_index + 1).str() +
				' '.repeat(buf.buffer.line_count().str().len - (y_index + 1).str().len))
			mut line_num_inactive_color := theme.inactive_line_number_color
			mut line_num_active_color := theme.active_line_number_color

			// determine cursor colors
			cursor_bg_color, cursor_fg_color := ctx.get_cursor_colors(buf.mode, theme)

			// get line indices and characters
			// line_indices := buf.visual_col[y_index] // column index for line

			mut text_color := colors.white

			if buf.p_mode == .directory {
				if fs.is_dir(buf.path + line) {
					line_num_label = ' '.repeat(buf.buffer.line_count().str().len)
					text_color = colors.royal_blue
				} else {
					file_ext := os.file_ext(line)
					if file_ext in constants.ext_icons {
						filetype := constants.ext_icons[file_ext]
						line_num_inactive_color = colors.hex_to_tui_color(filetype.color) or {
							colors.white
						}
						line_num_active_color = line_num_inactive_color
						line_num_label = filetype.icon +
							' '.repeat(buf.buffer.line_count().str().len - filetype.icon.len)
					} else {
						line_num_label = ' '.repeat(buf.buffer.line_count().str().len)
					}
				}
			}
			// highlight active line and render line numbers
			// this is rendered first, simulating line highlight over active line
			if y_index == buf.logical_cursor.y {
				// calculate how many lines that this line requires
				// (+ 1 since base is 0)
				total_lines := if line.len > 0 {
					(util.char_count_expanded_tabs(line, buf.tabsize) / view.width) + 1
				} else {
					1
				}

				ctx.set_colors(theme.active_line_bg_color, line_num_active_color)
				for wrap in 0 .. total_lines {
					active_line_index := i + wrap + wrap_offset + buffer_gap + 1
					if active_line_index > view.height {
						ctx.reset_colors()
						break render_lines
					}
					// not sure why +3 on end x
					ctx.draw_line(0, active_line_index, width - 1, active_line_index)
					ctx.draw_text(view.col_offset, i + wrap_offset + buffer_gap + 1, line_num_label)
				}
				ctx.reset_colors()
			} else {
				if i + wrap_offset + 1 > view.height {
					break render_lines
				}
				// render just line number for inactive line
				ctx.set_colors(theme.background_color, line_num_inactive_color)
				ctx.draw_text(view.col_offset, i + wrap_offset + buffer_gap + 1, line_num_label)
				ctx.reset_colors()
			}

			mut char_width := 1
			mut visual_cache := map[int]int{}
			mut col := 0
			for x_index, ch in line.runes_iterator() {
				visual_cache[x_index] = col
				mut printed := ch
				if ch == `\t` {
					printed = ` `
					char_width = buf.tabsize
					col += buf.tabsize - (col % buf.tabsize)
				} else {
					col++
				}
				visual_x_index := visual_cache[x_index]
				wraps = visual_x_index / view.width
				x_pos := visual_x_index % view.width + view.col_offset + view.line_num_to_text_gap
				y_pos := i + wraps + wrap_offset + buffer_gap

				if y_pos > view.height - buffer_gap {
					break render_lines
				}

				if x_index == buf.logical_cursor.x && y_index == buf.logical_cursor.y {
					view.visual_wraps = wrap_offset
					ctx.set_colors(cursor_bg_color, cursor_fg_color)
					ctx.draw_text(x_pos + 1, y_pos + 1, printed.str().repeat(char_width))
					ctx.reset_colors()
				} else if y_index == buf.logical_cursor.y {
					ctx.set_colors(theme.active_line_bg_color, text_color)
					ctx.draw_text(x_pos + 1, y_pos + 1, printed.str().repeat(char_width))
					ctx.reset_colors()
				} else {
					ctx.set_colors(theme.background_color, text_color)
					ctx.draw_text(x_pos + 1, y_pos + 1, printed.str().repeat(char_width))
					ctx.reset_colors()
				}
				char_width = 1
			}

			// Special case: cursor at end of line
			if buf.logical_cursor.y == y_index && buf.logical_cursor.x == line.runes().len {
				// find last column in this line (or 0 if empty)
				last_x := if line.runes().len > 0 {
					visual_cache[line.runes().len - 1] + 1
				} else {
					0
				}
				last_wraps := if line.runes().len > 0 { last_x / view.width } else { 0 }
				cursor_x := last_x % view.width + view.col_offset + view.line_num_to_text_gap
				cursor_y := i + last_wraps + wrap_offset + buffer_gap
				if cursor_y > view.height - buffer_gap {
					break render_lines
				}

				view.visual_wraps = wrap_offset
				ctx.set_colors(cursor_bg_color, cursor_fg_color)
				ctx.draw_text(cursor_x + 1, cursor_y + 1, ' ') // or just draw a block cursor
				ctx.reset_colors()
			}

			wrap_offset += wraps
		}
	} else {
		// draw for fuzzy
		start := 1 + buffer_gap
		start_x := buf.temp_data.len.str().len + 1
		input_string := '> ${buf.temp_label}'
		ctx.set_bg_color(theme.background_color)
		ctx.draw_text(1, start, input_string)
		file_count_text := '( walked: ${buf.temp_data.len} / ${buf.temp_int} )'
		ctx.draw_text(width - file_count_text.len - 2, start, file_count_text)
		if buf.mode == .insert {
			// the cursor is a lie but it looks good
			ctx.set_bg_color(theme.insert_cursor_color)
			ctx.draw_text(input_string.len + 1, start, ' ')
			if buf.temp_data.len > 0 {
				ctx.set_bg_color(theme.active_line_bg_color)
				ctx.draw_line(0, 1 + start, width - 1, 1 + start)
				ctx.draw_text(start_x + 1, 1 + start, buf.temp_data[0])
			}
			ctx.set_bg_color(theme.background_color)
		}
		for i, line in buf.temp_data[start_row..end_row] {
			mut line_num_label := ' '.repeat(buf.temp_data.len.str().len)
			file_ext := os.file_ext(line)
			if buf.mode == .normal && i == buf.logical_cursor.y {
				ctx.set_bg_color(theme.active_line_bg_color)
				ctx.draw_line(0, i + 1 + start, width - 1, i + 1 + start)
			}
			if file_ext in constants.ext_icons {
				filetype := constants.ext_icons[file_ext]
				fg_color := colors.hex_to_tui_color(filetype.color) or { colors.white }
				line_num_label = filetype.icon +
					' '.repeat(buf.buffer.line_count().str().len - filetype.icon.len)
				if buf.mode == .insert && i == 0 {
					ctx.set_bg_color(theme.active_line_bg_color)
				}
				ctx.set_color(fg_color)
				ctx.draw_text(1, i + 1 + start, line_num_label)
				ctx.reset_color()
			} else {
				line_num_label = ' '.repeat(buf.buffer.line_count().str().len)
				ctx.draw_text(1, i + 1 + start, line_num_label)
			}
			for j, ch in line.runes_iterator() {
				if buf.temp_label.contains(ch.str()) {
					ctx.set_color(colors.lavender_violet)
				}
				if buf.mode == .insert && i == 0 {
					ctx.set_bg_color(theme.active_line_bg_color)
					ctx.draw_text(j + 1 + start_x, i + 1 + start, ch.str())
				} else {
					ctx.draw_text(j + 1 + start_x, i + 1 + start, ch.str())
				}
				ctx.reset_color()
			}
			ctx.set_bg_color(theme.background_color)
		}
	}

	// debugging
	// ctx.draw_text(width - 30, height - 8, 'new_col: ' + new_col.str())
	// ctx.draw_text(width - 30, height - 7, 'wrap_points: ' + wrap_points.str())
	// ctx.draw_text(width - 30, height - 6, 'wrap_offset: ' + wrap_offset.str())
	// mut line := buf.lines[logical_idx]
	// mut wrap_points := view.build_wrap_points(line)
	// num_wraps := app.viewport.get_wrapped_index(wrap_points, buf.visual_cursor.y)
	// ctx.draw_text(width - 30, height - 5, 'x: ' + buf.visual_cursor.y.str())

	// ctx.draw_text(width - 30, height - 4, buf.char_index.str())
	// ctx.draw_text(width - 30, height - 3, '(' + buf.logical_cursor.x.str() + ', ' +
	// 	buf.logical_cursor.y.str() + ')')
	ctx.draw_text(width - 30, height - 3, buf.logical_cursor.flat_index.str())
	mut offset := 0
	for i in 0 .. buf.logical_cursor.y {
		offset += buf.buffer.line_at(i).len + 1 // +1 for newline
	}
	index := offset + buf.logical_cursor.x
	ctx.draw_text(width - 30, height - 2, index.str())

	mut command_bar_y_pos := height

	if buf.mode == util.Mode.command {
		command_bar_y_pos--
		// draw command bar
		ctx.set_bg_color(theme.command_bar_color)
		ctx.draw_line(0, command_bar_y_pos, width - 1, command_bar_y_pos)

		ctx.set_bg_color(util.get_command_bg_color(buf.mode, buf.p_mode))
		ctx.draw_line(4, command_bar_y_pos, command_str.len + 1 + 4, command_bar_y_pos)
		ctx.draw_text(5, command_bar_y_pos, term.bold(command_str))

		ctx.set_bg_color(theme.command_bar_color)
		// buf.path
		if buf.path.starts_with('Error') {
			ctx.set_color(colors.dark_red)
		} else {
			ctx.set_color(colors.white)
		}

		mut path_to_draw := buf.path
		if path_to_draw.len > width - 30 {
			buf_split := buf.path.split(os.path_separator)
			path_to_draw = '${buf_split[1] + os.path_separator} .. ${os.path_separator +
				buf_split[buf_split.len - 3..buf_split.len - 1].join(os.path_separator)}'
		}
		ctx.draw_text(command_str.len + 5 + 2, command_bar_y_pos, path_to_draw)
		ctx.reset_color()
		pos_string := (buf.logical_cursor.x + 1).str() + ':' + (buf.logical_cursor.y + 1).str()
		ctx.draw_text(width - pos_string.len, command_bar_y_pos, pos_string)

		ctx.reset_bg_color()

		// draw command mode prompt
		buf.logical_cursor.x = app.cmd_buffer.command.len + 2
		buf.logical_cursor.y = height

		ctx.set_bg_color(theme.background_color)
		// 1. Clear the entire command line with spaces
		// width is the terminal width
		ctx.draw_text(0, buf.logical_cursor.y, ' '.repeat(width - 1))

		// 2. Draw the ':' prompt
		ctx.draw_text(0, buf.logical_cursor.y, ':')

		// 3. Draw the command buffer
		ctx.draw_text(2, buf.logical_cursor.y, app.cmd_buffer.command)

		// 4. Draw the cursor block at the right position
		// cursor_pos := app.cmd_buffer.command.len + 2
		ctx.set_bg_color(theme.insert_cursor_color)
		ctx.draw_text(buf.logical_cursor.x, buf.logical_cursor.y, ' ')
		ctx.reset_bg_color()
	} else {
		// draw command bar
		ctx.set_bg_color(theme.command_bar_color)
		ctx.draw_line(0, command_bar_y_pos, width - 1, command_bar_y_pos)

		ctx.set_bg_color(util.get_command_bg_color(buf.mode, buf.p_mode))
		ctx.draw_line(4, command_bar_y_pos, command_str.len + 1 + 4, command_bar_y_pos)
		ctx.draw_text(5, command_bar_y_pos, term.bold(command_str))

		ctx.set_bg_color(theme.command_bar_color)
		// buf.path
		if buf.path.starts_with('Error') {
			ctx.set_color(colors.dark_red)
		} else {
			ctx.set_color(colors.white)
		}
		mut path_to_draw := buf.path
		if path_to_draw.len > width - 30 {
			buf_split := buf.path.split(os.path_separator)
			path_to_draw = '${buf_split[1] + os.path_separator} .. ${os.path_separator +
				buf_split[buf_split.len - 3..buf_split.len - 1].join(os.path_separator)}'
		}
		ctx.draw_text(command_str.len + 5 + 2, command_bar_y_pos, path_to_draw)
		ctx.reset_color()
		pos_string := (buf.logical_cursor.x + 1).str() + ':' + (buf.logical_cursor.y + 1).str()
		ctx.draw_text(width - pos_string.len, command_bar_y_pos, pos_string)

		ctx.reset_bg_color()
	}

	// update_cursor(buf.logical_cursor.x, buf.logical_cursor.y, mut ctx)
	ctx.flush()
	// ctx.paused = true
}
