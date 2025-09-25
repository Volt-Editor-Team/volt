module controller

import util.fuzzy

pub fn handle_insert_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	// global normal mode
	if event == .key_down {
		match key {
			.escape {
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
						delete_result := buf.remove_char(buf.logical_cursor.x, buf.logical_cursor.y)
						if delete_result.joined_line {
							buf.logical_cursor.move_up_buffer(buf.logical_x)
						}
						buf.logical_cursor.move_to_x(delete_result.new_x)
						buf.update_visual_cursor(app.viewport.width)
						buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
					}
					.enter {
						buf.insert_newline(buf.logical_cursor.x, buf.logical_cursor.y)
						buf.logical_cursor.move_to_start_next_line_buffer(buf.lines, buf.logical_x)
						buf.update_visual_cursor(app.viewport.width)

						buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
					}
					else {
						if is_printable_key(key) {
							buf.insert_char(buf.logical_cursor.x, buf.logical_cursor.y,
								u8(key).ascii_str())

							buf.logical_cursor.move_right_buffer(buf.lines)
							buf.update_visual_cursor(app.viewport.width)
							buf.logical_cursor.update_desired_col(buf.visual_cursor.x,
								app.viewport.width)
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
							else {}
						}
					}
					else {
						match key {
							.backspace {
								app.stop_flag = true
								if buf.temp_label.len > 0 {
									buf.temp_label = buf.temp_label[..buf.temp_label.len - 1]
									app.stop_flag = false
									fuzzy.fuzzyfind(buf.temp_label, mut buf.temp_data, mut
										&app.stop_flag)
								}
							}
							else {
								if is_printable_key(key) {
									app.stop_flag = true
									buf.temp_label += key.str()
									app.stop_flag = false
									fuzzy.fuzzyfind(buf.temp_label, mut buf.temp_data, mut
										&app.stop_flag)
								}
							}
						}
					}
				}
			}
		}
	}
}
