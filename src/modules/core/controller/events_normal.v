module controller

pub fn handle_normal_mode_event(x voidptr, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	if event == .key_down {
		match key {
			.i {
				buf.mode = .insert
			}
			.colon {
				buf.saved_cursor = buf.logical_cursor
				buf.mode = .command
			}
			.l, .right {
				buf.logical_cursor.move_right_buffer(buf.lines)
				buf.update_visual_cursor(app.viewport.width)
				buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
			}
			.h, .left {
				buf.logical_cursor.move_left_buffer(buf.lines)
				buf.update_visual_cursor(app.viewport.width)
				buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
			}
			.j, .down {
				line := buf.visual_col[buf.logical_cursor.y]

				// total wraps in the current line
				mut total_wraps := 0
				if line.len != 0 {
					total_wraps = line[line.len - 1] / app.viewport.width
				}

				// current wrap index
				cur_wrap := buf.visual_cursor.x / app.viewport.width

				if cur_wrap < total_wraps {
					buf.visual_cursor.x += app.viewport.width
					buf.logical_cursor.x = buf.logical_x(buf.logical_cursor.y, buf.visual_cursor.x)
				} else {
					buf.logical_cursor.move_down_buffer(buf.lines, buf.logical_x)
				}

				// update visual cursor to match logical cursor
				buf.update_visual_cursor(app.viewport.width)

				// update viewport offset
				buf.update_offset(app.viewport.visual_wraps, app.viewport.height, app.viewport.margin)
			}
			.k, .up {
				cur_wrap := buf.visual_cursor.x / app.viewport.width
				if cur_wrap == 0 {
					if buf.logical_cursor.y - 1 > 0 {
						line := buf.visual_col[buf.logical_cursor.y - 1]

						mut total_wraps := 0
						if line.len != 0 {
							total_wraps = line[line.len - 1] / app.viewport.width
						}
						if total_wraps > 0 {
							buf.logical_cursor.y--
							buf.visual_cursor.x += total_wraps * app.viewport.width
							buf.logical_cursor.x = buf.logical_x(buf.logical_cursor.y,
								buf.visual_cursor.x)
						} else {
							buf.logical_cursor.move_up_buffer(buf.logical_x)
						}
					} else {
						buf.logical_cursor.move_up_buffer(buf.logical_x)
					}
				} else {
					buf.visual_cursor.x -= app.viewport.width
					buf.logical_cursor.x = buf.logical_x(buf.logical_cursor.y, buf.visual_cursor.x)
				}

				buf.update_visual_cursor(app.viewport.width)
				// update offset
				buf.update_offset(app.viewport.visual_wraps, app.viewport.height, app.viewport.margin)
			}
			// next two key bindings are bad. using them for testing
			.b {
				if app.buffers.len > 1 {
					if app.active_buffer == 0 {
						app.active_buffer = app.buffers.len - 1
					} else {
						app.active_buffer -= 1
					}
				}
			}
			.n {
				if app.buffers.len > 1 {
					if app.active_buffer == app.buffers.len - 1 {
						app.active_buffer = 0
					} else {
						app.active_buffer += 1
					}
				}
			}
			else {}
		}
	}
}
