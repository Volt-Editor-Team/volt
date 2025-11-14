module controller

pub fn handle_menu_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	if event == .key_down {
		match buf.p_mode {
			.default, .directory {
				match key {
					.q {
						app.cmd_buffer.command = ''
						if buf.p_mode == .directory {
							app.has_directory_buffer = false
						}
						if buf.name == 'DOCTOR' {
							app.has_stats_opened = false
						}
						app.close_buffer()
					}
					.escape {
						buf.mode = .normal
					}
					else {
						buf.mode = .normal
					}
				}
			}
			.fuzzy {
				match key {
					.q {
						app.cmd_buffer.command = ''
						if buf.p_mode == .directory {
							app.has_directory_buffer = false
						}
						if buf.name == 'DOCTOR' {
							app.has_stats_opened = false
						}
						app.close_buffer()
					}
					else {
						buf.mode = .normal
					}
				}
			}
		}
	}
}
