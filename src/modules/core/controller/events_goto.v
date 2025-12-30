module controller

pub fn handle_goto_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	mut view := &app.viewport
	if event == .key_down {
		match mod {
			.none {
				match key {
					.l {
						if buf.p_mode != .fuzzy {
							// shouldn't just exit normally if the line is empty
							cur_line := view.visible_lines[view.cursor.y - view.row_offset]
							if cur_line.len > 0 {
								view.cursor.move_to_x(cur_line, cur_line.len - 1, view.tabsize)
								view.update_offset(buf.buffer)
								// view.fill_visible_lines(buf.buffer)
								view.cursor.update_desired_col(app.viewport.width)
							}
							buf.mode = .normal
							buf.menu_state = false
						}
					}
					.h {
						if buf.p_mode != .fuzzy {
							cur_line := view.visible_lines[view.cursor.y - view.row_offset]
							view.cursor.move_to_x(cur_line, 0, view.tabsize)
							view.update_offset(buf.buffer)
							// view.fill_visible_lines(buf.buffer)
							view.cursor.update_desired_col(app.viewport.width)
							buf.mode = .normal
							buf.menu_state = false
						}
					}
					.s {
						if buf.p_mode != .fuzzy {
							cur_line := view.visible_lines[view.cursor.y - view.row_offset]
							mut index := 0
							for ch in cur_line {
								if !ch.str().is_blank() {
									break
								}
								index++
							}
							view.cursor.move_to_x(cur_line, index, view.tabsize)
							view.update_offset(buf.buffer)
							// view.fill_visible_lines(buf.buffer)
							view.cursor.update_desired_col(app.viewport.width)
							buf.mode = .normal
							buf.menu_state = false
						}
					}
					.g {
						if buf.p_mode == .fuzzy {
							buf.temp_cursor.y = 0
							view.update_offset_for_temp(buf.temp_cursor.y)
						} else {
							view.cursor.y = 0
							view.cursor.x = 0
							mut offset := 0
							for i in 0 .. view.cursor.y {
								offset += buf.buffer.line_at(i).len + 1 // +1 for newline
							}
							cur_line := buf.buffer.line_at(view.cursor.y)
							view.cursor.flat_index = offset + view.cursor.x
							view.cursor.move_to_x(cur_line, view.cursor.x, view.tabsize)
						}
						view.cursor.update_desired_col(app.viewport.width)
						view.update_offset(buf.buffer)
						view.fill_visible_lines(buf.buffer)
						view.cursor.update_desired_col(app.viewport.width)
						buf.mode = .normal
						buf.menu_state = false
					}
					.e {
						if buf.p_mode == .fuzzy {
							buf.temp_cursor.y = buf.temp_data.len - 1
							view.update_offset_for_temp(buf.temp_cursor.y)
						} else {
							view.cursor.y = buf.buffer.line_count() - 1
							view.cursor.x = 0
							view.cursor.update_desired_col(app.viewport.width)
							cur_line := buf.buffer.line_at(view.cursor.y)
							view.cursor.flat_index = (buf.buffer.len() - 1) - (cur_line.len - 1)
							view.cursor.move_to_x(cur_line, view.cursor.x, view.tabsize)
							view.update_offset(buf.buffer)
							view.fill_visible_lines(buf.buffer)
							view.cursor.update_desired_col(app.viewport.width)
						}
						buf.mode = .normal
						buf.menu_state = false
					}
					else {
						buf.mode = .normal
						buf.menu_state = false
					}
				}
			}
			.shift {
				match key {
					.e {
						if buf.p_mode == .fuzzy {
							buf.temp_cursor.y = buf.temp_data.len - 1
							view.update_offset_for_temp(buf.temp_cursor.y)
						} else {
							view.cursor.y = buf.buffer.line_count() - 1
							view.cursor.x = 0
							cur_line := buf.buffer.line_at(view.cursor.y)
							view.cursor.flat_index = buf.buffer.len() - 1
							view.cursor.move_to_x(cur_line, cur_line.len - 1, view.tabsize)
							view.cursor.update_desired_col(app.viewport.width)
							view.update_offset(buf.buffer)
							view.fill_visible_lines(buf.buffer)
						}
						buf.mode = .normal
						buf.menu_state = false
					}
					else {}
				}
			}
			else {}
		}
	}
}
