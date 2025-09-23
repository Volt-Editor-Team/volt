module controller

pub fn handle_fuzzy_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	if event == .key_down {
		if buf.mode == .insert {
		} else {
			match mod {
				.ctrl {
					match key {
						.j, .down {}
						.k, .up {}
						.q {
							saved_buf := app.swap_map[app.active_buffer]
							// buf.label = saved_buf.label
							buf.name = saved_buf.name
							buf.path = saved_buf.path
							buf.p_mode = saved_buf.p_mode
							buf.mode = buf.p_mode
							buf.lines = saved_buf.lines
							buf.logical_cursor = saved_buf.logical_cursor
							buf.visual_cursor = saved_buf.visual_cursor
							buf.saved_cursor = saved_buf.saved_cursor
							buf.row_offset = saved_buf.row_offset
							buf.update_all_line_cache()
						}
						else {}
					}
				}
				else {}
			}
		}
	}
}
