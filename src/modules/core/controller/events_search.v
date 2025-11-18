module controller

pub fn handle_search_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	// global normal mode
	if event == .key_down {
		match key {
			.exclamation {
				buf.menu_state = !buf.menu_state
			}
			// file fuzzy finder
			.escape {
				buf.mode = .normal
				buf.menu_state = false
			}
			.f {
				if buf.p_mode != .fuzzy {
					app.cmd_buffer.command = ''
					buf.temp_string = app.working_dir
					buf.mode = .insert
					buf.open_fuzzy_find(app.working_dir, .file)
				}
			}
			// directory fuzzy finder
			.d {
				if buf.p_mode != .fuzzy {
					app.cmd_buffer.command = ''
					buf.temp_string = app.working_dir
					buf.mode = .insert
					buf.open_fuzzy_find(app.working_dir, .directory)
				}
			}
			// f<char>
			else {}
		}
	}
}
