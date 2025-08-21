module controller

import term.ui as tui

pub fn event(e &tui.Event, x voidptr) {
	mut app := get_app(x)

	if e.typ == .key_down {
		match app.mode {
			.normal {
				match e.code {
					.l {
						app.cursor.move_right_buffer(app.buffer)
					}
					.h {
						app.cursor.move_left_buffer(app.buffer)
					}
					.j {
						app.cursor.move_down_buffer(app.buffer)
						if app.viewport.update_offset(app.cursor.y) {
							app.tui.reset()
						}
					}
					.k {
						app.cursor.move_up_buffer(app.buffer)
						if app.viewport.update_offset(app.cursor.y) {
							app.tui.reset()
						}
					}
					.i {
						app.mode = .insert
					}
					.colon {
						app.saved_cursor = app.cursor
						app.mode = .command
					}
					else {}
				}
			}
			.insert {
				match e.code {
					.escape {
						app.mode = .normal
					}
					.backspace {
						delete_result := app.buffer.remove_char(app.cursor.x, app.cursor.y)
						if delete_result.joined_line {
							app.cursor.move_up_buffer(app.buffer)
						}
						app.cursor.move_to_x(app.buffer, delete_result.new_x)
					}
					.enter {
						app.buffer.insert_newline(app.cursor.x, app.cursor.y)
						app.cursor.move_to_start_next_line_buffer(app.buffer)
					}
					else {
						app.buffer.insert_char(app.cursor.x, app.cursor.y, e.ascii.ascii_str())
						app.cursor.move_right_buffer(app.buffer)
					}
				}
			}
			.command {
				match e.code {
					.enter {
						match app.cmd_buffer {
							'q' {
								app.cmd_buffer = ''
								exit(0)
							}
							else {}
						}
					}
					.escape {
						app.mode = .normal
						app.cursor = app.saved_cursor
						app.cmd_buffer = ''
					}
					.backspace {
						before := app.cmd_buffer[..app.cursor.x - 2]
						after := app.cmd_buffer[app.cursor.x - 1..]
						app.cmd_buffer = before + after
					}
					else {
						ch := e.ascii.ascii_str()
						app.cmd_buffer += ch
					}
				}
			}
		}
	}
}
