module controller

import time
import fs { read_file, write_file }

pub fn handle_command_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]

	if event == .key_down {
		cmd_str := app.cmd_buffer.command
		if buf.p_mode == .fuzzy && mod == .ctrl && key == .q {
			// restore settings
			buf.path = buf.temp_path
			buf.p_mode = buf.temp_mode
			buf.mode = .normal
			buf.logical_cursor = buf.temp_cursor
			// buf.update_visual_cursor(app.viewport.width)
			buf.update_offset(app.viewport.visual_wraps, app.viewport.height, app.viewport.margin)
			// delete temp stuff
			buf.temp_label = ''
			buf.temp_data.clear()
		}
		match key {
			.escape {
				buf.mode = .normal
				app.cmd_buffer.command = ''
				buf.logical_cursor = buf.saved_cursor
				// 	buf.update_visual_cursor(app.viewport.width)
			}
			.enter {
				match cmd_str {
					'q', 'quit' {
						app.cmd_buffer.command = ''
						exit(0)
					}
					'w', 'write' {
						match buf.p_mode {
							.directory {}
							else {
								result, message := write_file(buf.path, buf.lines)
								if result {
									// do something
									_ := message
								} else {
									buf.lines = read_file(buf.path) or { [''] }
									// buf.update_all_line_cache()
								}
								app.cmd_buffer.command = ''
								buf.mode = .normal
								buf.logical_cursor = buf.saved_cursor
								// 					buf.update_visual_cursor(app.viewport.width)
							}
						}
					}
					'help' {
						buf.mode = .normal
						app.cmd_buffer.command = ''
						app.add_help_buffer()
					}
					'cd' {
						buf.mode = .normal
						app.cmd_buffer.command = ''

						if app.has_directory_buffer {
							for i, buffer in app.buffers {
								if buffer.p_mode == .directory {
									app.active_buffer = i
								}
							}
						} else {
							app.add_directory_buffer()
							// 				// buf.update_visual_cursor(app.viewport.width)
							app.has_directory_buffer = true
						}
					}
					'cb' {
						app.cmd_buffer.command = ''
						if buf.p_mode == .directory {
							app.has_directory_buffer = false
						}
						if buf.name == 'DOCTOR' {
							app.has_stats_opened = false
						}
						app.close_buffer()
					}
					'doctor' {
						buf.mode = .normal
						app.cmd_buffer.command = ''
						buf.logical_cursor = buf.saved_cursor
						// 			buf.update_visual_cursor(app.viewport.width)
						if app.has_stats_opened {
							for i, buffer in app.buffers {
								if buffer.name == 'DOCTOR' {
									app.active_buffer = i
								}
							}
						} else {
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
							app.has_stats_opened = true
						}
					}
					'fzf' {
						app.cmd_buffer.command = ''
						buf.open_fuzzy_find()
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
