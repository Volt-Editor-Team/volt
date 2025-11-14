module controller

// buffer change command : b,n

pub fn event_loop(input UserInput, x voidptr) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]

	match buf.mode {
		.normal {
			handle_normal_mode_event(x, input.mod, input.e, input.code)
		}
		.insert {
			match input.code {
				.up, .down, .left, .right {
					handle_normal_mode_event(x, input.mod, input.e, input.code)
				}
				else {
					handle_insert_mode_event(x, input.mod, input.e, input.code)
				}
			}
		}
		.command {
			handle_command_mode_event(x, input.mod, input.e, input.code)
		}
		.menu {
			handle_menu_mode_event(x, input.mod, input.e, input.code)
		}
		.goto {
			handle_goto_mode_event(x, input.mod, input.e, input.code)
		}
		.search {
			handle_search_mode_event(x, input.mod, input.e, input.code)
		}
	}
}
