module controller

pub fn handle_menu_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	match buf.p_mode {
		.default, .directory {
			if event == .key_down {
				match key {
					.escape {
						buf.mode = .normal
					}
					else {
						buf.mode = .normal
					}
				}
			}
		}
		else {
			buf.mode = .normal
		}
	}
}
