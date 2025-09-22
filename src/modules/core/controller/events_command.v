module controller

import time
import fs { read_file, write_file }

pub fn handle_command_mode_event(x voidptr, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]

	if event == .key_down {
		cmd_str := app.cmd_buffer.command
		match key {
			.escape {
				buf.mode = buf.p_mode
				app.cmd_buffer.command = ''
				buf.logical_cursor = buf.saved_cursor
				buf.update_visual_cursor(app.viewport.width)
			}
			.enter {
				match cmd_str {
					'q', 'quit' {
						app.cmd_buffer.command = ''
						exit(0)
					}
					'w', 'write' {
						result, message := write_file(buf.path, buf.lines)
						if result {
							// do something
							_ := message
						} else {
							buf.lines = read_file(buf.path) or { [''] }
							// buf.update_all_line_cache()
						}
						app.cmd_buffer.command = ''
						buf.mode = buf.p_mode
						buf.logical_cursor = buf.saved_cursor
						buf.update_visual_cursor(app.viewport.width)
					}
					'cd' {
						buf.mode = buf.p_mode
						app.add_directory_buffer()
						app.cmd_buffer.command = ''
						buf.update_visual_cursor(app.viewport.width)
					}
					'cb' {
						app.close_buffer()
						app.cmd_buffer.command = ''
						buf.logical_cursor = buf.saved_cursor
						buf.update_visual_cursor(app.viewport.width)
					}
					'doctor' {
						buf.mode = buf.p_mode
						if app.stats.len == 0 {
							go fn [mut buf] () {
								temp := buf.path
								buf.path = 'Error: Stats not available'
								time.sleep(2 * time.second)
								buf.path = temp
							}()
							return
						}
						app.add_stats_buffer()
						app.cmd_buffer.command = ''
						buf.logical_cursor = buf.saved_cursor
						buf.update_visual_cursor(app.viewport.width)
					}
					else {}
				}
			}
			.backspace {
				// // command string start at x = 2
				// command_str_index := buf.logical_cursor.x - 2
				// remove char before index
				if app.cmd_buffer.command.len > 0 {
					app.cmd_buffer.remove_char(app.cmd_buffer.command.len - 1)
				}
			}
			else {
				ch := u8(key).ascii_str()
				app.cmd_buffer.command += ch
			}
		}
	}
}
