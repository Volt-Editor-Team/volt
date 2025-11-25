module controller

import time
// import fs
import os

pub fn handle_command_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	mut view := &app.viewport

	if event == .key_down {
		cmd_str := buf.cmd.command
		if buf.p_mode == .fuzzy && mod == .ctrl && key == .q {
			// restore settings
			// buf.path = buf.temp_path
			buf.p_mode = buf.temp_mode
			buf.mode = .normal
			buf.logical_cursor = buf.temp_cursor
			view.update_offset(app.buffers[app.active_buffer].logical_cursor.y, buf.buffer)
			// delete temp stuff
			buf.temp_label = ''
			buf.temp_data.clear()
		}
		match key {
			.escape {
				if buf.prev_mode == .insert {
					buf.change_mode(.insert, buf.menu_state)
				} else {
					buf.change_mode(.normal, buf.menu_state)
				}
				buf.cmd.command = ''
				// buf.logical_cursor = buf.saved_cursor
			}
			.enter {
				command := cmd_str[2..]
				if command.starts_with('cd') && command.len > 2 {
					return
				}
				// simple commands
				match command {
					// quit
					'q', 'quit' {
						exit(0)
					}
					// write/save file
					'w', 'write' {
						match buf.p_mode {
							.directory {}
							else {
								// ! more interface implementation first !
								// result, message := write_file(buf.path, buf.lines)
								// if result {
								// 	// do something
								// 	_ := message
								// } else {
								// 	buf.lines = read_file(buf.path) or { [''] }
								// 	// buf.update_all_line_cache()
								// }
								// buf.cmd.command = ''
								// buf.mode = .normal
								// buf.logical_cursor = buf.saved_cursor
								// // 					buf.update_visual_cursor(app.viewport.width)
							}
						}
					}
					// help
					'h', 'help' {
						buf.mode = .normal
						buf.cmd.command = ''
						app.add_help_buffer()
					}
					// change directory buffer
					'cd', 'change-directory' {
						buf.mode = .normal
						buf.cmd.command = ''

						if app.has_directory_buffer {
							for i, buffer in app.buffers {
								if buffer.p_mode == .directory {
									app.active_buffer = i
								}
							}
						} else {
							app.add_directory_buffer()
							app.has_directory_buffer = true
						}
					}
					// close buffer
					'cb', 'close-buffer' {
						buf.cmd.command = ''
						if buf.p_mode == .directory {
							app.has_directory_buffer = false
						}
						if buf.name == 'DOCTOR' {
							app.has_stats_opened = false
						}
						app.close_buffer()
					}
					// print working directory
					'pwd', 'print-working-directory' {
						buf.mode = .normal
						buf.cmd.command = 'Working Directory: ' + os.getwd()
					}
					// open doctor
					'doc', 'doctor' {
						buf.mode = .normal
						buf.cmd.command = ''
						if app.has_stats_opened {
							for i, buffer in app.buffers {
								if buffer.name == 'DOCTOR' {
									app.active_buffer = i
								}
							}
						} else {
							if app.stats.len == 0 {
								go fn [mut buf] () {
									// temp := buf.path
									// buf.path = 'Error: Stats not available'
									// time.sleep(2 * time.second)
									// buf.path = temp
									buf.cmd.command = 'Error: Stats not available'
									time.sleep(2 * time.second)
									buf.cmd.command = ''
								}()
								return
							}
							app.get_doctor_info()
							app.add_stats_buffer()
							app.has_stats_opened = true
						}
					}
					// fuzzy finder
					'fzf', 'fuzzy-find' {
						buf.cmd.command = ''
						buf.open_fuzzy_find(app.working_dir, .file)
					}
					'btype', 'buffer-type' {
						buf.mode = .normal
						buf.cmd.command = 'Buffer type: ${buf.type}'
					}
					'encoding' {
						buf.mode = .normal
						buf.cmd.command = buf.encoding.str()
					}
					else {}
				}
			}
			// delete character
			.backspace {
				// remove char before index
				if buf.cmd.command.len > 2 {
					buf.cmd.remove_char(buf.cmd.command.len - 1)
				}
			}
			// add character
			else {
				ch := u8(key).ascii_str()
				buf.cmd.command += ch
			}
		}
	}
}
