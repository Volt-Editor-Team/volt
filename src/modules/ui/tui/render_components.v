module tui

import viewport { Viewport }
import buffer { Buffer }
import buffer.common { BufferInterface }

import util.colors
import term
import util
import os
import math

fn (mut tui_app TuiApp) rerender_viewport(mut view Viewport, buf BufferInterface) bool {
	width, height := term.get_terminal_size()
	view_width := if width > 0 { width } else { 1 } // minimum width = 1
	view_height := if height > 1 { height } else { 1 } // minimum height = 1
	if view.width != view_width || view.height != view_height {
		view.width = view_width
		view.height = view_height
		view.reload(buf)
		return true
	}
	return false
}

fn (mut tui_app TuiApp) draw_menu(buf Buffer, view Viewport) {
	mut command_str := util.mode_str(buf.mode, buf.p_mode, buf.prev_mode)
	mut ctx := tui_app.tui
	if buf.menu_state == true && buf.mode != .insert {
		mut key_bindings := map[string]string{}
		$if windows {
		    key_bindings = normal_menu_windows.clone()
		}
		$if macos {
		    key_bindings = normal_menu.clone()
		}
		$if linux {
		    key_bindings = normal_menu.clone()
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
		menu_top := view.height / 3
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

		menu_left := view.width / 2 - (max_key_length + max_value_length + 6) / 2
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

}

fn (mut tui_app TuiApp) draw_command_bar(buf Buffer, view Viewport) {
	mut command_str := util.mode_str(buf.mode, buf.p_mode, buf.prev_mode)
	mut ctx := tui_app.tui

	mut command_bar_y_pos := view.height

	if buf.mode == .command || buf.cmd.command.len > 2 {
		command_bar_y_pos--
		// draw command menu
		// draw command bar
		ctx.set_bg_color(tui_app.theme.command_bar_color)
		ctx.draw_line(0, command_bar_y_pos, view.width - 1, command_bar_y_pos)

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
		if path_to_draw.len > view.width - 30 {
			buf_split := buf.path.split(os.path_separator)
			path_to_draw = '${buf_split[1] + os.path_separator} .. ${os.path_separator +
				buf_split[buf_split.len - 3..buf_split.len - 1].join(os.path_separator)}'
		}
		ctx.draw_text(command_str.len + 5 + 2, command_bar_y_pos, path_to_draw)
		ctx.reset_color()
		pos_string := if buf.p_mode == .fuzzy {
			(buf.temp_cursor.x + 1).str() + ':' + (buf.temp_cursor.y + 1).str()
		} else {
			(view.cursor.x + 1).str() + ':' + (view.cursor.y + 1).str()
		}
		ctx.draw_text(view.width - pos_string.len, command_bar_y_pos, pos_string)

		ctx.reset_bg_color()

		// draw command mode prompt
		// if buf.mode == .command {
		// 	view.cursor.x = buf.cmd.command.len + 2
		// 	view.cursor.y =view.height
		// }

		ctx.set_bg_color(tui_app.theme.background_color)
		// 1. Clear the entire command line with spaces
		// view.width is the terminalview.width
		ctx.draw_text(0, view.height, ' '.repeat(view.width - 1))

		// 2. Draw the ':' prompt
		// ctx.draw_text(0, view.cursor.y, ':')

		// 3. Draw the command buffer
		if buf.cmd.command.starts_with('Error') {
			ctx.set_color(colors.dark_red)
		} else if buf.cmd.command.starts_with('Success') {
			ctx.set_color(colors.sea_green)
		} else {
			ctx.set_color(colors.white)
		}

		ctx.draw_text(2, view.height, buf.cmd.command)

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
				section_width := (view.width - left_pad) / num_sections
				cmd_menu_top := command_bar_y_pos - if commands.len > 1 {
					math.min(6, (commands.len / num_sections) + 1)
				} else {
					3
				}
				cmd_menu_bottom := command_bar_y_pos - 1
				ctx.set_bg_color(colors.dark_grey_blue)
				ctx.draw_rect(0, cmd_menu_top, view.width - 1, cmd_menu_bottom)

				for i, command in commands {
					cmd_x := left_pad + (i % num_sections) * section_width
					cmd_y := cmd_menu_top + (i / num_sections)
					if commands.len == 1 {
						ctx.draw_text(cmd_x, cmd_y, command.name)
						ctx.draw_text(cmd_x, cmd_y + 1, command.aliases.str())
						ctx.draw_text(cmd_x, cmd_y + 2, command.desc)
					}
					for offset, ch in command.name.runes() {
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
			ctx.draw_text(buf.cmd.command.len + 2, view.height, ' ')
			ctx.reset_bg_color()
		}
	} else {
		// draw command bar
		ctx.set_bg_color(tui_app.theme.command_bar_color)
		ctx.draw_line(0, command_bar_y_pos, view.width - 1, command_bar_y_pos)

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
		if path_to_draw.len > view.width - 30 {
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
			(view.cursor.x + 1).str() + ':' + (view.cursor.y + 1).str()
		}
		ctx.draw_text(view.width - pos_string.len, command_bar_y_pos, pos_string)

		ctx.reset_bg_color()
	}
}
