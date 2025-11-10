module controller

pub fn handle_goto_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	if event == .key_down {
		match key {
			.g {
				buf.logical_cursor.y = 0
				buf.logical_cursor.x = 0
				buf.logical_cursor.update_desired_col(app.viewport.width)
				mut offset := 0
				for i in 0 .. buf.logical_cursor.y {
					offset += buf.buffer.line_at(i).len + 1 // +1 for newline
				}
				buf.logical_cursor.flat_index = offset + buf.logical_cursor.x
				buf.logical_cursor.move_to_x(buf.buffer, buf.logical_cursor.x, buf.tabsize)
				buf.update_offset(app.viewport.visual_wraps, app.viewport.height, app.viewport.margin)
				buf.mode = .normal
			}
			.e {
				buf.logical_cursor.y = buf.buffer.line_count() - 1
				line := buf.buffer.line_at(buf.logical_cursor.y)
				buf.logical_cursor.x = line.len
				buf.logical_cursor.update_desired_col(app.viewport.width)
				mut visual_wraps := 0
				mut cur_index := buf.logical_cursor.y - 1
				for cur_index + visual_wraps > buf.logical_cursor.y - app.viewport.height - app.viewport.margin
					&& cur_index >= 0 {
					visual_wraps += buf.buffer.line_at(cur_index).len / app.viewport.width
					cur_index--
				}
				mut offset := 0
				for i in 0 .. buf.logical_cursor.y {
					offset += buf.buffer.line_at(i).len + 1 // +1 for newline
				}
				buf.logical_cursor.flat_index = offset + buf.logical_cursor.x
				buf.logical_cursor.move_to_x(buf.buffer, buf.logical_cursor.x, buf.tabsize)
				buf.update_offset(visual_wraps, app.viewport.height, app.viewport.margin)
				buf.mode = .normal
			}
			else {
				buf.mode = .normal
			}
		}
	}
}
