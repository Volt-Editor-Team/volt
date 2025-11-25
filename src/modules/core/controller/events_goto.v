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
							if buf.cur_line.len > 0 {
								buf.logical_cursor.move_to_x(buf.cur_line, buf.cur_line.len - 1,
									view.tabsize)
								view.update_offset(app.buffers[app.active_buffer].logical_cursor.y,
									buf.buffer)
								// view.fill_visible_lines(buf.buffer)
								buf.logical_cursor.update_desired_col(app.viewport.width)
							}
							buf.mode = .normal
							buf.menu_state = false
						}
					}
					.h {
						if buf.p_mode != .fuzzy {
							buf.logical_cursor.move_to_x(buf.cur_line, 0, view.tabsize)
							view.update_offset(app.buffers[app.active_buffer].logical_cursor.y,
								buf.buffer)
							// view.fill_visible_lines(buf.buffer)
							buf.logical_cursor.update_desired_col(app.viewport.width)
							buf.mode = .normal
							buf.menu_state = false
						}
					}
					.s {
						if buf.p_mode != .fuzzy {
							mut index := 0
							for ch in buf.cur_line {
								if !ch.str().is_blank() {
									break
								}
								index++
							}
							buf.logical_cursor.move_to_x(buf.cur_line, index, view.tabsize)
							view.update_offset(app.buffers[app.active_buffer].logical_cursor.y,
								buf.buffer)
							// view.fill_visible_lines(buf.buffer)
							buf.logical_cursor.update_desired_col(app.viewport.width)
							buf.mode = .normal
							buf.menu_state = false
						}
					}
					.g {
						if buf.p_mode == .fuzzy {
							buf.logical_cursor.y = 0
						} else {
							buf.logical_cursor.y = 0
							buf.logical_cursor.x = 0
							mut offset := 0
							for i in 0 .. buf.logical_cursor.y {
								offset += buf.buffer.line_at(i).len + 1 // +1 for newline
							}
							buf.cur_line = buf.buffer.line_at(buf.logical_cursor.y)
							buf.logical_cursor.flat_index = offset + buf.logical_cursor.x
							buf.logical_cursor.move_to_x(buf.cur_line, buf.logical_cursor.x,
								view.tabsize)
						}
						buf.logical_cursor.update_desired_col(app.viewport.width)
						view.update_offset(app.buffers[app.active_buffer].logical_cursor.y,
							buf.buffer)
						view.fill_visible_lines(buf.buffer)
						buf.logical_cursor.update_desired_col(app.viewport.width)
						buf.mode = .normal
						buf.menu_state = false
					}
					.e {
						if buf.p_mode == .fuzzy {
							buf.logical_cursor.y = buf.temp_data.len - 1
							view.update_offset(app.buffers[app.active_buffer].logical_cursor.y,
								buf.buffer)
						} else {
							buf.logical_cursor.y = buf.buffer.line_count() - 1
							buf.logical_cursor.x = 0
							buf.logical_cursor.update_desired_col(app.viewport.width)
							buf.cur_line = buf.buffer.line_at(buf.logical_cursor.y)
							buf.logical_cursor.flat_index = buf.buffer.len() - (buf.cur_line.len - 1)
							buf.logical_cursor.move_to_x(buf.cur_line, buf.logical_cursor.x,
								view.tabsize)
							view.update_offset(app.buffers[app.active_buffer].logical_cursor.y,
								buf.buffer)
							view.fill_visible_lines(buf.buffer)
							buf.logical_cursor.update_desired_col(app.viewport.width)
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
							buf.logical_cursor.y = buf.temp_data.len - 1
							view.update_offset(app.buffers[app.active_buffer].logical_cursor.y,
								buf.buffer)
						} else {
							buf.logical_cursor.y = buf.buffer.line_count() - 1
							buf.logical_cursor.x = 0
							buf.cur_line = buf.buffer.line_at(buf.logical_cursor.y)
							buf.logical_cursor.flat_index = buf.buffer.len() - (buf.cur_line.len - 1)
							buf.logical_cursor.move_to_x(buf.cur_line, buf.cur_line.len - 1,
								view.tabsize)
							buf.logical_cursor.update_desired_col(app.viewport.width)
							view.update_offset(app.buffers[app.active_buffer].logical_cursor.y,
								buf.buffer)
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
