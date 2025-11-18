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
						mut ch := rune(int(key))
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
		.fuzzy {
			if event == .key_down {
				match mod {
					.shift {
						match key {
							.enter {}
							// for switch fuzzy search directory
							.tab {
								// buf.path = buf.temp_path

								// delete temp stuff
								buf.temp_label = ''
								buf.temp_data.clear()
								buf.file_ch.close()
								buf.p_mode = buf.temp_mode

								buf.temp_string = os.dir(buf.temp_string)
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

									// delete temp stuff
									buf.temp_label = ''
									buf.temp_data.clear()
									buf.file_ch.close()
									buf.temp_string += os.path_separator + file

									buf.p_mode = buf.temp_mode
									if os.is_dir(buf.temp_string) {
										buf.open_fuzzy_find(buf.temp_string, .directory)
									}
								}
							}
							.enter {
								if buf.temp_data.len > 0 {
									file := buf.temp_data[buf.logical_cursor.y].string()

									// buf.path = buf.temp_path
									buf.p_mode = buf.temp_mode
									buf.mode = .normal
									buf.logical_cursor = buf.temp_cursor
									buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
										app.viewport.margin)
									buf.file_ch.close()

									// delete temp stuff
									mut path := buf.temp_string + os.path_separator + file

									if os.is_dir(path) {
										dir_path := path + os.path_separator
										for mut buffer in app.buffers {
											full_path := app.working_dir + os.path_separator +
												buffer.path
											if full_path.starts_with(dir_path) {
												buffer.path = full_path.replace(dir_path,
													'')
											} else {
												buffer.path = full_path
											}
										}
										os.chdir(path) or { return }
										app.working_dir = path
									} else {
										app.add_new_buffer(
											name:    os.file_name(file)
											path:    path
											tabsize: buf.tabsize
											type:    .gap
											mode:    .normal
											p_mode:  .default
										)
										if path.starts_with(app.working_dir + os.path_separator) {
											app.buffers[app.active_buffer].path = path.replace(
												app.working_dir + os.path_separator, '')
										}
									}
									buf.temp_label = ''
									buf.temp_data.clear()
									buf.menu_state = false
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
								buf.temp_label += rune(int(key)).str()
								if buf.logical_cursor.y > buf.temp_data.len {
									buf.logical_cursor.y = 0
									buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
										app.viewport.margin)
								}
							}
						}
					}
				}
			}
		}
	}
}
