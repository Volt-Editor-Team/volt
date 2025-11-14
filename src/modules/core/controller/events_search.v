module controller

pub fn handle_search_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	// global normal mode
	if event == .key_down {
		match key {
			// file fuzzy finder
			.f {
				app.cmd_buffer.command = ''
				buf.open_fuzzy_find()
			}
			// directory fuzzy finder
			.d {}
			// f<char>
			else {}
		}
	}
}
