module tui

import core.controller
import util
import util.colors
import util.constants
import term
import math
import os

fn full_redraw(x voidptr) {
	width, height := term.get_terminal_size()

	// get app pointer, terminal size, and clear to prep for updates
	mut tui_app := get_tui(x)
	mut ctx := tui_app.tui
	mut app := controller.get_app(tui_app.core)

	// relavent info for rendering
	mut view := &app.viewport
	mut buf := &app.buffers[app.active_buffer]
	if buf.needs_render || buf.p_mode == .fuzzy {
		mut command_str := util.mode_str(buf.mode, buf.p_mode, buf.prev_mode)

		// --- draw background ---
		ctx.draw_background(1, 1, width, height, tui_app.theme.background_color)

		// --- draw tabs for multiple buffers ---
		multiple_buffers := app.buffers.len > 1
		buffer_gap := int(multiple_buffers)
		if multiple_buffers {
			buffer_names := []string{len: app.buffers.len, init: ' ' + app.buffers[index].name + ' '}
			ctx.draw_tabs(buffer_names, app.active_buffer, width, tui_app.theme)
		}

		start_row := view.row_offset
		mut end_row := start_row

		if buf.p_mode == .fuzzy {
			end_row = math.min(buf.temp_data.len, view.row_offset + view.height)
		} else {
			end_row = math.min(buf.buffer.line_count(), view.row_offset + view.height)
		}
		mut allocated_line_num_width := math.max(buf.buffer.line_count().str().len, 5)

		match buf.p_mode {
			.default {
				view.col_offset = 2
			}
			.directory {
				view.col_offset = 2
				allocated_line_num_width = 1
			}
			.fuzzy {
				view.col_offset = 2
				end_row = math.min(buf.temp_data.len, view.row_offset + view.height)
				allocated_line_num_width = 1
			}
		}

		// --- render text ---
		if buf.p_mode != .fuzzy {
			// render loop
			mut wrap_offset := 0
			mut wraps := 0
			render_lines: for i in 0 .. end_row - start_row {
				// i is the row index of the actual renders screen
				// y_index is the position in the buffer
				y_index := start_row + i
				// line := buf.buffer.line_at(y_index)
				line := if view.visible_lines.len > 0 { view.visible_lines[i].string() } else { '' }

				// values necessary for rendering aligned line numbers

				// determine cursor colors
				cursor_bg_color, cursor_fg_color := ctx.get_cursor_colors(buf.mode, tui_app.theme)

				// get line indices and characters
				line_num_label, text_color, line_num_active_color, line_num_inactive_color := ctx.get_gutter_label_and_colors(buf.path,
					line, y_index, allocated_line_num_width, buf.p_mode, tui_app.theme)

				// highlight active line and render line numbers
				// this is rendered first, simulating line highlight over active line
				if y_index == buf.logical_cursor.y {
					// calculate how many lines that this line requires
					// (+ 1 since base is 0)
					total_lines := if line.len_utf8() > 0 {
						(line.expand_tabs(view.tabsize).len_utf8() / view.width) + 1
					} else {
						1
					}

					ctx.set_colors(tui_app.theme.active_line_bg_color, line_num_active_color)
					for wrap in 0 .. total_lines {
						active_line_index := i + wrap + wrap_offset + buffer_gap + 1
						if active_line_index > view.height {
							ctx.reset_colors()
							break render_lines
						}
						// not sure why +3 on end x
						ctx.draw_line(0, active_line_index, width - 1, active_line_index)
						ctx.draw_text(view.col_offset, i + wrap_offset + buffer_gap + 1,
							line_num_label)
					}
					ctx.reset_colors()
				} else {
					if i + wrap_offset + 1 > view.height {
						break render_lines
					}
					// render just line number for inactive line
					ctx.set_colors(tui_app.theme.background_color, line_num_inactive_color)
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
						char_width = view.tabsize
						col += view.tabsize - (col % view.tabsize)
					} else {
						col++
					}
					visual_x_index := visual_cache[x_index]
					wraps = visual_x_index / view.width
					x_pos := visual_x_index % view.width + view.col_offset +
						allocated_line_num_width + 1
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
						ctx.set_colors(tui_app.theme.active_line_bg_color, text_color)
						ctx.draw_text(x_pos + 1, y_pos + 1, printed.str().repeat(char_width))
						ctx.reset_colors()
					} else {
						ctx.set_colors(tui_app.theme.background_color, text_color)
						ctx.draw_text(x_pos + 1, y_pos + 1, printed.str().repeat(char_width))
						ctx.reset_colors()
					}
					char_width = 1
				}

				// Special case: cursor at end of line
				if buf.logical_cursor.y == y_index && buf.logical_cursor.x == line.len {
					// find last column in this line (or 0 if empty)
					// last_index := line[line.len - 1]
					last_x := if line.len > 0 {
						// visual_cache[line.len - 1] + char_width
						col
					} else {
						0
					}
					last_wraps := if line.len > 0 { last_x / view.width } else { 0 }
					cursor_x := last_x % view.width + view.col_offset + allocated_line_num_width + 1
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
			// draw input line
			mut start := 1 + buffer_gap
			first_line := start
			allocated_line_num_width = 1
			input_string := '> ${buf.temp_label}'
			ctx.set_bg_color(tui_app.theme.background_color)
			ctx.draw_text(1, start, input_string)
			file_count_text := '( walked: ${buf.temp_data.len} / ${buf.temp_int} )'
			ctx.draw_text(width - file_count_text.len - 2, first_line, file_count_text)

			start_x := allocated_line_num_width + 2

			start++ // increment to draw after input line

			// draw selections
			ctx.set_color(colors.deep_indigo)
			for i, selected in buf.temp_list {
				selected_path := selected.replace(buf.temp_path + os.path_separator, '')
				file_ext := os.file_ext(selected)
				if file_ext in constants.ext_icons {
					filetype := constants.ext_icons[file_ext]
					fg_color := colors.hex_to_tui_color(filetype.color) or { colors.white }
					line_num_label := filetype.icon +
						' '.repeat(allocated_line_num_width - filetype.icon.len)
					ctx.set_color(fg_color)
					ctx.draw_text(1, i + start, line_num_label)
					ctx.set_color(colors.deep_indigo)
				}

				ctx.draw_text(start_x, start + i, selected_path)
			}
			ctx.reset_color()
			start += buf.temp_list.len // increment to draw after selections
			if buf.mode == .insert {
				// draw the input string to match
				// the cursor is a lie but it looks good
				ctx.set_bg_color(tui_app.theme.insert_cursor_color)
				ctx.draw_text(input_string.len + 1, first_line, ' ')
				if buf.temp_data.len > 0 {
					ctx.set_bg_color(tui_app.theme.active_line_bg_color)
					ctx.draw_line(0, start, width - 1, start)
					ctx.draw_text(start_x, start, buf.temp_data[0].string())
				}
				ctx.set_bg_color(tui_app.theme.background_color)
			}
			// start -= buf.temp_list.len // increment to draw after selections

			// draw search results
			for i, line_runes in buf.temp_data#[start_row..end_row] {
				line := line_runes.string()
				y_index := i + start_row
				mut line_num_label := ' '.repeat(buf.temp_data.len.str().len)
				file_ext := os.file_ext(line)
				// highlight cursor line
				if (buf.mode != .insert && y_index == buf.temp_cursor.y)
					|| (buf.mode == .insert && i + start_row == 0) {
					ctx.set_bg_color(tui_app.theme.active_line_bg_color)
					ctx.draw_line(0, i + start, width - 1, i + start)
				} else {
					ctx.set_bg_color(tui_app.theme.background_color)
				}
				// draw icon if file
				// if not file, fill with spaces
				if file_ext in constants.ext_icons {
					filetype := constants.ext_icons[file_ext]
					fg_color := colors.hex_to_tui_color(filetype.color) or { colors.white }
					line_num_label = filetype.icon +
						' '.repeat(allocated_line_num_width - filetype.icon.len)
					if buf.mode == .insert && i == 0 {
						ctx.set_bg_color(tui_app.theme.active_line_bg_color)
					}
					ctx.set_color(fg_color)
					ctx.draw_text(1, i + start, line_num_label)
					ctx.reset_color()
				} else {
					line_num_label = ' '.repeat(allocated_line_num_width)
					ctx.draw_text(1, i + start, line_num_label)
				}
				// draw actual line characters
				for j, ch in line_runes {
					mut char_to_draw := ch.str()
					if buf.temp_label.contains(ch.str()) {
						ctx.set_color(colors.lavender_violet)
					}
					if buf.temp_list.contains(buf.temp_path + os.path_separator +
						line_runes.string())
					{
						ctx.set_color(colors.dark_red)
						if j == line_runes.len - 1 {
							char_to_draw += ' [ SELECTED ]'
						}
					}
					if buf.mode == .insert && i == 0 {
						ctx.set_bg_color(tui_app.theme.active_line_bg_color)
						ctx.draw_text(j + start_x, i + start, char_to_draw)
					} else {
						ctx.draw_text(j + start_x, i + start, char_to_draw)
					}
					ctx.reset_color()
				}
			}
		}

		// -- draw menu --
		if buf.menu_state == true && buf.mode != .insert {
			mut key_bindings := if app.os == 'windows' {
				normal_menu_windows.clone()
			} else {
				normal_menu.clone()
			}
			match buf.mode {
				.normal {
					match buf.p_mode {
						.default {}
						.fuzzy {
							key_bindings = fuzzy_menu.clone()
						}
						.directory {
							key_bindings = directory_menu.clone()
						}
					}
				}
				.insert {}
				.command {}
				.menu {
					key_bindings = menu_menu.clone()
				}
				.goto {
					key_bindings = if buf.p_mode == .fuzzy {
						fuzzy_goto_menu.clone()
					} else {
						goto_menu.clone()
					}
				}
				.search {
					if buf.prev_mode == .menu {
						key_bindings = menu_menu.clone()
					} else {
						key_bindings = search_menu.clone()
					}
				}
			}
			menu_top := height / 3
			menu_bottom := menu_top + key_bindings.len + 1
			mut max_key_length := 0
			for key in key_bindings.keys() {
				if key.len > max_key_length {
					max_key_length = key.len
				}
			}
			mut max_value_length := 0
			for value in key_bindings.values() {
				if value.len > max_value_length {
					max_value_length = value.len
				}
			}

			menu_left := width / 2 - (max_key_length + max_value_length + 6) / 2
			menu_right := menu_left + max_key_length + max_value_length + 6
			ctx.draw_background(menu_left, menu_top, menu_right, menu_bottom, colors.dark_grey_blue)
			ctx.set_colors(colors.dark_grey_blue, tui_app.theme.normal_text_color)
			for x_pos in menu_left + 1 .. menu_right {
				ctx.draw_text(x_pos, menu_top, '-')
				ctx.draw_text(x_pos, menu_bottom, '-')
			}
			for y_pos in menu_top + 1 .. menu_bottom {
				ctx.draw_text(menu_left, y_pos, '|')
				ctx.draw_text(menu_right, y_pos, '|')
			}

			mut i := 0
			ctx.draw_text(menu_left + 3, menu_top, command_str)
			for key, value in key_bindings {
				ctx.draw_text(menu_left + 2, menu_top + i + 1, key + ' '.repeat(2 +
					(max_key_length - key.len)) + value)
				i++
			}
		}

		// -- debugging --
		// if view.visible_lines.len > 0 {
		// ctx.draw_text(width - 90, height - 5, view.visible_lines#[-5..].str())
		// 	ctx.draw_text(width - 90, height - 4, view.visible_lines[buf.logical_cursor.y - view.row_offset].str())
		// }
		// ctx.draw_text(width - 90, height - 3, buf.logical_cursor.flat_index.str())
		// ctx.draw_text(width - 90, height - 2, buf.buffer.line_count().str())

		// -- status bar --
		mut command_bar_y_pos := height

		if buf.mode == .command || buf.cmd.command.len > 2 {
			command_bar_y_pos--
			// draw command menu
			// draw command bar
			ctx.set_bg_color(tui_app.theme.command_bar_color)
			ctx.draw_line(0, command_bar_y_pos, width - 1, command_bar_y_pos)

			ctx.set_bg_color(util.get_command_bg_color(buf.mode, buf.p_mode))
			ctx.draw_line(4, command_bar_y_pos, command_str.len + 1 + 4, command_bar_y_pos)
			ctx.draw_text(5, command_bar_y_pos, term.bold(command_str))

			ctx.set_bg_color(tui_app.theme.command_bar_color)
			// buf.path

			mut path_to_draw := if buf.label == 'Scratch' && buf.name == 'Scratch' {
				'Scratch'
			} else {
				buf.path
			}
			if path_to_draw.len > width - 30 {
				buf_split := buf.path.split(os.path_separator)
				path_to_draw = '${buf_split[1] + os.path_separator} .. ${os.path_separator +
					buf_split[buf_split.len - 3..buf_split.len - 1].join(os.path_separator)}'
			}
			ctx.draw_text(command_str.len + 5 + 2, command_bar_y_pos, path_to_draw)
			ctx.reset_color()
			pos_string := if buf.p_mode == .fuzzy {
				(buf.temp_cursor.x + 1).str() + ':' + (buf.temp_cursor.y + 1).str()
			} else {
				(buf.logical_cursor.x + 1).str() + ':' + (buf.logical_cursor.y + 1).str()
			}
			ctx.draw_text(width - pos_string.len, command_bar_y_pos, pos_string)

			ctx.reset_bg_color()

			// draw command mode prompt
			// if buf.mode == .command {
			// 	buf.logical_cursor.x = buf.cmd.command.len + 2
			// 	buf.logical_cursor.y = height
			// }

			ctx.set_bg_color(tui_app.theme.background_color)
			// 1. Clear the entire command line with spaces
			// width is the terminal width
			ctx.draw_text(0, height, ' '.repeat(width - 1))

			// 2. Draw the ':' prompt
			// ctx.draw_text(0, buf.logical_cursor.y, ':')

			// 3. Draw the command buffer
			if buf.cmd.command.starts_with('Error') {
				ctx.set_color(colors.dark_red)
			} else {
				ctx.set_color(colors.white)
			}
			ctx.draw_text(2, height, buf.cmd.command)

			// 4. Draw the cursor block at the right position
			// cursor_pos := buf.cmd.command.len + 2
			if buf.mode == util.Mode.command {
				commands := command_menu.filter(it.name.starts_with(buf.cmd.command[2..])
					|| it.aliases.any(it.starts_with(buf.cmd.command[2..])))

				// if buf.cmd.command.len > 2 {
				// 	mut matching_commands := commands.filter(
				// 		it.name.starts_with(buf.cmd.command[2..])
				// 		|| it.aliases.any(it.starts_with(buf.cmd.command[2..])))
				// 	if matching_commands.len > 0 {
				// 		commands = unsafe { matching_commands }
				// 	}
				// }
				if commands.len > 0 {
					left_pad := 3
					num_sections := 5
					section_width := (width - left_pad) / num_sections
					cmd_menu_top := command_bar_y_pos - if commands.len > 1 {
						math.min(6, (commands.len / num_sections) + 1)
					} else {
						3
					}
					cmd_menu_bottom := command_bar_y_pos - 1
					ctx.set_bg_color(colors.dark_grey_blue)
					ctx.draw_rect(0, cmd_menu_top, width - 1, cmd_menu_bottom)

					for i, command in commands {
						cmd_x := left_pad + (i % num_sections) * section_width
						cmd_y := cmd_menu_top + (i / num_sections)
						if commands.len == 1 {
							ctx.draw_text(cmd_x, cmd_y, command.name)
							ctx.draw_text(cmd_x, cmd_y + 1, command.aliases.str())
							ctx.draw_text(cmd_x, cmd_y + 2, command.desc)
						}
						for offset, ch in command.name.runes_iterator() {
							if buf.cmd.command.contains(ch.str()) && offset <= buf.cmd.command.len {
								ctx.set_color(colors.lavender_violet)
							}
							ctx.draw_text(cmd_x + offset, cmd_y, ch.str())
							ctx.reset_color()
						}
						// ctx.draw_text(cmd_x, cmd_y, command.name)
					}
					ctx.reset_bg_color()
				}

				ctx.set_bg_color(tui_app.theme.insert_cursor_color)
				ctx.draw_text(buf.cmd.command.len + 2, height, ' ')
				ctx.reset_bg_color()
			}
		} else {
			// draw command bar
			ctx.set_bg_color(tui_app.theme.command_bar_color)
			ctx.draw_line(0, command_bar_y_pos, width - 1, command_bar_y_pos)

			ctx.set_bg_color(util.get_command_bg_color(buf.mode, buf.p_mode))
			ctx.draw_line(4, command_bar_y_pos, command_str.len + 1 + 4, command_bar_y_pos)
			ctx.draw_text(5, command_bar_y_pos, term.bold(command_str))

			ctx.set_bg_color(tui_app.theme.command_bar_color)
			// buf.path
			mut path_to_draw := if buf.label == 'Scratch' && buf.name == 'Scratch' {
				'Scratch'
			} else {
				buf.path
			}
			if path_to_draw.len > width - 30 {
				buf_split := buf.path.split(os.path_separator)
				path_to_draw = '${buf_split[1] + os.path_separator} .. ${os.path_separator +
					buf_split[buf_split.len - 3..buf_split.len - 1].join(os.path_separator)}'
			}
			// if buf.cmd.command.starts_with('Error') {
			// 	ctx.set_color(colors.dark_red)
			// } else {
			// 	ctx.set_color(colors.white)
			// }
			ctx.draw_text(command_str.len + 5 + 2, command_bar_y_pos, path_to_draw)
			ctx.reset_color()
			pos_string := if buf.p_mode == .fuzzy {
				(buf.temp_cursor.x + 1).str() + ':' + (buf.temp_cursor.y + 1).str()
			} else {
				(buf.logical_cursor.x + 1).str() + ':' + (buf.logical_cursor.y + 1).str()
			}
			ctx.draw_text(width - pos_string.len, command_bar_y_pos, pos_string)

			ctx.reset_bg_color()
		}

		// update_cursor(buf.logical_cursor.x, buf.logical_cursor.y, mut ctx)
		ctx.flush()
		buf.needs_render = false
	}
}
