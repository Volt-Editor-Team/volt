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
							app.stop_flag = true
							// restore settings
							buf.path = buf.temp_path
							buf.p_mode = buf.temp_mode
							buf.mode = .normal
							buf.logical_cursor = buf.temp_cursor
							buf.update_visual_cursor(app.viewport.width)
							buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
								app.viewport.margin)

							// delete temp stuff
							buf.temp_label = ''
							buf.temp_data.clear()
							app.stop_flag = false
						}
						else {}
					}
				}
				else {}
			}
		}
	}
}
