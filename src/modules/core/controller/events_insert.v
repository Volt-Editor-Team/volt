module controller

import os

pub fn handle_insert_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	// global normal mode
	if event == .key_down {
		match key {
			.escape {
				// not for temporary buffers
				if buf.p_mode != .fuzzy || buf.p_mode != .directory {
					buf.prev_mode = buf.mode
				}
				buf.mode = .normal
				return
			}
			else {}
		}
	}
	// specific to persistant mode
	match buf.p_mode {
		.default, .directory {
			if event == .key_down {
				match key {
					.backspace {
						prev_line_len := if buf.logical_cursor.y > 0 {
							buf.buffer.line_at(buf.logical_cursor.y - 1).len
						} else {
							0
						}
						total_lines := buf.buffer.line_count()
						buf.buffer.delete(buf.logical_cursor.flat_index - 1, 1) or { return }
						buf.cur_line = buf.buffer.line_at(buf.logical_cursor.y)
						// delete_result := buf.remove_char(buf.logical_cursor.x, buf.logical_cursor.y)
						if buf.buffer.line_count() != total_lines {
							buf.logical_cursor.flat_index += buf.buffer.line_at(buf.logical_cursor.y - 1).len - prev_line_len
							buf.logical_cursor.move_up_buffer(mut buf.cur_line, buf.buffer,
								buf.tabsize)
							buf.logical_cursor.move_to_x(buf.cur_line, prev_line_len,
								buf.tabsize)
						} else {
							if buf.logical_cursor.x > 0 {
								buf.logical_cursor.move_to_x(buf.cur_line, buf.logical_cursor.x - 1,
									buf.tabsize)
							}
						}
						buf.logical_cursor.update_desired_col(app.viewport.width)
					}
					.enter {
						buf.buffer.insert(buf.logical_cursor.flat_index, `\n`) or { return }
						buf.logical_cursor.move_to_start_next_line_buffer(mut buf.cur_line,
							buf.buffer, buf.tabsize)
						buf.logical_cursor.update_desired_col(app.viewport.width)
					}
					else {
						if is_printable_key(key) {
							mut ch := u8(key).ascii_str()
							if mod == .shift {
								ch = ch.to_upper()
							}

							buf.buffer.insert(buf.logical_cursor.flat_index, ch) or { return }
							buf.cur_line = buf.buffer.line_at(buf.logical_cursor.y)

							buf.logical_cursor.move_right_buffer(mut buf.cur_line, buf.buffer,
								buf.tabsize)
							buf.logical_cursor.update_desired_col(app.viewport.width)
						}
					}
				}
			}
		}
		.fuzzy {
			if event == .key_down {
				match mod {
					.shift {
						match key {
							.enter {}
							// for switch fuzzy search directory
							.tab {
								// file := buf.temp_data[buf.logical_cursor.y].string()

								// buf.path = buf.temp_path
								buf.p_mode = buf.temp_mode
								buf.mode = .normal
								buf.logical_cursor = buf.temp_cursor
								buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
									app.viewport.margin)

								// delete temp stuff
								// buf.temp_data.clear()
								buf.file_ch.close()

								search_path := if buf.temp_string == '' {
									app.working_dir
								} else {
									os.abs_path(buf.temp_string)
								}
								buf.temp_string = os.abs_path(os.dir(search_path))
								if os.is_dir(buf.temp_string) {
									buf.open_fuzzy_find(buf.temp_string, .directory)
								}
							}
							else {}
						}
					}
					.ctrl {
						match key {
							.q {
								// restore settings
								buf.path = buf.temp_path
								buf.p_mode = buf.temp_mode
								buf.mode = .normal
								buf.logical_cursor = buf.temp_cursor
								buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
									app.viewport.margin)

								// delete temp stuff
								buf.temp_label = ''
								buf.temp_data.clear()
								buf.file_ch.close()
							}
							else {}
						}
					}
					else {
						match key {
							// for switch fuzzy search directory
							.tab {
								if buf.temp_data.len > 0 {
									file := buf.temp_data[buf.logical_cursor.y].string()

									buf.path = buf.temp_path
									buf.p_mode = buf.temp_mode
									buf.mode = .normal
									buf.logical_cursor = buf.temp_cursor
									buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
										app.viewport.margin)

									// delete temp stuff
									buf.temp_label = ''
									// buf.temp_data.clear()
									buf.file_ch.close()
									buf.temp_string = os.abs_path(file)

									if os.is_dir(buf.temp_string) {
										buf.open_fuzzy_find(buf.temp_string, .directory)
									}
								}
							}
							.enter {
								if buf.temp_data.len > 0 {
									buf.path = buf.temp_path
									buf.p_mode = buf.temp_mode
									buf.mode = .normal
									buf.logical_cursor = buf.temp_cursor
									buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
										app.viewport.margin)

									file := buf.temp_data[0].string()
									app.add_new_buffer(
										name:    os.file_name(file)
										path:    file
										tabsize: buf.tabsize
										mode:    .normal
										p_mode:  .default
									)
									// delete temp stuff
									buf.temp_label = ''
									buf.temp_data.clear()
								}
							}
							.backspace {
								if buf.temp_label.len > 0 {
									buf.temp_label = buf.temp_label[..buf.temp_label.len - 1]
								}
							}
							.colon {
								buf.saved_cursor = buf.logical_cursor
								buf.mode = .command
							}
							else {
								if is_printable_key(key) {
									buf.temp_label += key.str()
								}
							}
						}
					}
				}
			}
		}
	}
}
