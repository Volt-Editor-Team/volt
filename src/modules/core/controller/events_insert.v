module controller

pub fn handle_insert_mode_event(x voidptr, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	if event == .key_down {
		match key {
			.escape {
				buf.mode = buf.p_mode
			}
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
				buf.insert_char(buf.logical_cursor.x, buf.logical_cursor.y, u8(key).ascii_str())

				buf.logical_cursor.move_right_buffer(buf.lines)
				buf.update_visual_cursor(app.viewport.width)
				buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
			}
		}
	}
}
