module controller

import os
import util

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
							buf.logical_cursor.move_up_buffer(buf, buf.tabsize)
						}
						buf.logical_cursor.move_to_x(delete_result.new_x)
						// buf.update_visual_cursor(app.viewport.width)
						// buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
						cur_line := buf.line_at(buf.logical_cursor.y)
						visual_index := util.char_count_expanded_tabs(cur_line#[..
							buf.logical_cursor.x + 1], buf.tabsize)
						buf.logical_cursor.update_desired_col(visual_index, app.viewport.width)
					}
					.enter {
						// --- map cursor to character index
						mut offset := 0
						for i in 0 .. buf.logical_cursor.y {
							offset += buf.line_at(i).len + 1 // +1 for newline
						}
						index := offset + buf.logical_cursor.x
						// ---
						buf.insert(index, `\n`) or { return }
						// buf.insert_newline(buf.logical_cursor.x, buf.logical_cursor.y)
						buf.logical_cursor.move_to_start_next_line_buffer(buf, buf.tabsize)
						// buf.update_visual_cursor(app.viewport.width)

						// buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
						cur_line := buf.line_at(buf.logical_cursor.y)
						visual_index := util.char_count_expanded_tabs(cur_line#[..
							buf.logical_cursor.x + 1], buf.tabsize)
						buf.logical_cursor.update_desired_col(visual_index, app.viewport.width)
					}
					else {
						if is_printable_key(key) {
							mut ch := u8(key).ascii_str()
							if mod == .shift {
								ch = ch.to_upper()
							}
							// --- map cursor to character index
							mut offset := 0
							for i in 0 .. buf.logical_cursor.y {
								offset += buf.line_at(i).len + 1 // +1 for newline
							}
							index := offset + buf.logical_cursor.x
							// ---

							buf.insert(index, ch) or { return }
							// buf.insert_char(buf.logical_cursor.x, buf.logical_cursor.y,
							// 	ch)

							buf.logical_cursor.move_right_buffer(buf)
							// 	buf.update_visual_cursor(app.viewport.width)
							// buf.logical_cursor.update_desired_col(buf.visual_cursor.x,
							// 	app.viewport.width)
							cur_line := buf.line_at(buf.logical_cursor.y)
							visual_index := util.char_count_expanded_tabs(cur_line#[..
								buf.logical_cursor.x + 1], buf.tabsize)
							buf.logical_cursor.update_desired_col(visual_index, app.viewport.width)
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
							.colon {
								buf.saved_cursor = buf.logical_cursor
								buf.mode = .command
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
								// 		buf.update_visual_cursor(app.viewport.width)
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
							.enter {
								if buf.temp_data.len > 0 {
									buf.path = buf.temp_path
									buf.p_mode = buf.temp_mode
									buf.mode = .normal
									buf.logical_cursor = buf.temp_cursor
									// 			buf.update_visual_cursor(app.viewport.width)
									buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
										app.viewport.margin)

									file := buf.temp_data[0]
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
