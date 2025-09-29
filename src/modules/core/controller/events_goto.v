module controller

import math

pub fn handle_goto_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	if event == .key_down {
		match key {
			.g {
				buf.logical_cursor.y = 0
				buf.logical_cursor.x = 0
				buf.update_visual_cursor(app.viewport.width)
				buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
				buf.update_offset(app.viewport.width, app.viewport.height, app.viewport.margin)
				buf.mode = .normal
			}
			.e {
				buf.logical_cursor.y = buf.lines.len - 1
				buf.logical_cursor.x = buf.lines[buf.logical_cursor.y].len
				buf.update_visual_cursor(app.viewport.width)
				buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
				buf.update_offset(app.viewport.width, app.viewport.height, app.viewport.margin)
				buf.mode = .normal
			}
			else {
				buf.mode = .normal
			}
		}
	}
}
