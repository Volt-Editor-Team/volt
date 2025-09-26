module controller

import time
import fs { read_file, write_file }
import util.fuzzy
import os

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
			buf.update_visual_cursor(app.viewport.width)
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
				buf.update_visual_cursor(app.viewport.width)
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
								buf.update_visual_cursor(app.viewport.width)
							}
						}
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
							// buf.update_visual_cursor(app.viewport.width)
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
						buf.update_visual_cursor(app.viewport.width)
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
					'fuzzy' {
						app.cmd_buffer.command = ''
						buf.temp_path = buf.path
						buf.temp_cursor = buf.logical_cursor
						buf.temp_mode = buf.p_mode

						buf.path = os.getwd()
						buf.p_mode = .fuzzy
						buf.mode = .insert

						buf.logical_cursor.x = 0
						buf.logical_cursor.y = 0
						buf.row_offset = 0
						buf.update_visual_cursor(app.viewport.width)

						// walk path
						go fn [buf] () {
							walk_path := fs.get_dir_or_parent_dir(buf.path)
							os.walk(walk_path, fn [buf] (file string) {
								if buf.p_mode == .fuzzy {
									if file.contains(os.path_separator + '.git' + os.path_separator) {
										return
									}
									if os.is_file(file) {
										buf.file_ch <- file[buf.path.len + 1..]
									}
								}
							})
						}()

						// worker thread
						go fn [mut buf] () {
							mut last_query := ''
							for {
								if buf.p_mode != .fuzzy {
									time.sleep(100 * time.millisecond)
									continue
								}

								// non-blocking channel receive with timeout
								select {
									file := <-buf.file_ch {
										buf.temp_data << file
									}
									else {
										// no file available, continue
									}
								}
								if buf.temp_label != last_query {
									lock buf.stop_flag {
										buf.stop_flag.flag = true
									}
									lock buf.stop_flag {
										buf.stop_flag.flag = false
									}
									last_query = buf.temp_label
									fuzzy.fuzzyfind(buf.temp_label, mut buf.temp_data,
										unsafe { buf.check_stop_flag })
								}
								// time.sleep(1 * time.millisecond)
							}
						}()
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
