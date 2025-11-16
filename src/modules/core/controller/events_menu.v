module controller

import time

pub fn handle_menu_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	if event == .key_down {
		match buf.p_mode {
			.default, .directory {
				match key {
					.exclamation {
						buf.menu_state = !buf.menu_state
					}
					.f {
						temp := buf.prev_mode
						buf.prev_mode = buf.mode
						buf.mode = .search
						timer := time.now()
						go fn [app, mut buf, timer, temp] () {
							buf.menu_state = false
							for buf.prev_mode == .menu && buf.mode == .search {
								if time.since(timer).milliseconds() > 200 {
									buf.open_fuzzy_find(app.working_dir, .file)
									break
								}
							}
							buf.menu_state = true
							buf.prev_mode = temp
						}()
					}
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
						buf.menu_state = false
					}
					else {
						buf.mode = .normal
						buf.menu_state = false
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
						buf.menu_state = false
					}
				}
			}
		}
	}
}
