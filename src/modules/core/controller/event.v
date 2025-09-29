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
		// .directory {
		// 	match input.code {
		// 		.k, .up, .j, .down, .h, .left, .l, .right, .colon, .i {
		// 			handle_normal_mode_event(x, input.e, input.code)
		// 		}
		// 		else {
		// 			handle_directory_mode_event(x, input.e, input.code)
		// 		}
		// 	}
		// }
		// .fuzzy {
		// 	match input.code {
		// 		.colon, .b, .n {
		// 			handle_normal_mode_event(x, input.e, input.code)
		// 		}
		// 		else {
		// 			handle_fuzzy_mode_event(x, input.mod, input.e, input.code)
		// 		}
		// 	}
		// }
	}
}
