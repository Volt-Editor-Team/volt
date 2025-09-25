module controller

// import fs

// pub fn handle_directory_mode_event(x voidptr, event EventType, key KeyCode) {
// 	mut app := get_app(x)
// 	mut buf := &app.buffers[app.active_buffer]
// 	if event == .key_down {
// 		match key {
// 			// next two key bindings are bad. using them for testing
// 			.b {
// 				if app.buffers.len > 1 {
// 					if app.active_buffer == 0 {
// 						app.active_buffer = app.buffers.len - 1
// 					} else {
// 						app.active_buffer -= 1
// 					}
// 				}
// 			}
// 			.n {
// 				if app.buffers.len > 1 {
// 					if app.active_buffer == app.buffers.len - 1 {
// 						app.active_buffer = 0
// 					} else {
// 						app.active_buffer += 1
// 					}
// 				}
// 			}
// 			else {}
// 		}
// 	}
// }
