module controller

pub fn event_loop(input UserInput, x voidptr) {
	mut app := get_app(x)

	match app.mode {
		.normal {
			handle_normal_mode_event(x, input.e, input.code)
		}
		.insert {
			handle_insert_mode_event(x, input.e, input.code)
		}
		.command {
			handle_command_mode_event(x, input.e, input.code)
		}
	}
}
