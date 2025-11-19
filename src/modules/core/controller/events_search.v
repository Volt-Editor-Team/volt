module controller

pub fn handle_search_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	// global normal mode
	if event == .key_down {
		// file fuzzy finder
		if key == .f && buf.prev_mode == .menu && buf.p_mode != .fuzzy {
			buf.temp_path = app.working_dir
			buf.mode = .insert
			buf.temp_fuzzy_type = .file
			buf.open_fuzzy_find(app.working_dir, .file)
			return
		}
		// directory fuzzy finder
		if key == .d && buf.prev_mode == .menu && buf.p_mode != .fuzzy {
			buf.temp_path = app.working_dir
			buf.mode = .insert
			buf.temp_fuzzy_type = .dir
			buf.open_fuzzy_find(app.working_dir, .directory)
			return
		}
		match key {
			.exclamation {
				buf.menu_state = !buf.menu_state
			}
			.escape {
				buf.mode = .normal
				buf.menu_state = false
			}
			// f<char>
			else {}
		}
	}
}
