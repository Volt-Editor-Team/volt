module controller

import term.ui as tui

pub fn event(e &tui.Event, x voidptr) {
	mut app := get_app(x)

	if e.typ == .key_down {
		match app.mode {
			.normal {
				match e.code {
					.l {
						app.logical_cursor.move_right_buffer(app.buffer)
						app.visual_cursor.update(app.buffer, mut app.logical_cursor)
					}
					.h {
						app.logical_cursor.move_left_buffer(app.buffer)
						app.visual_cursor.update(app.buffer, mut app.logical_cursor)
					}
					.j {
						app.logical_cursor.move_down_buffer(app.buffer)
						app.visual_cursor.update(app.buffer, mut app.logical_cursor)
						if app.viewport.update_offset(app.visual_cursor.y) {
							app.tui.reset()
						}
					}
					.k {
						app.logical_cursor.move_up_buffer(app.buffer)
						app.visual_cursor.update(app.buffer, mut app.logical_cursor)
						if app.viewport.update_offset(app.visual_cursor.y) {
							app.tui.reset()
						}
					}
					.i {
						app.mode = .insert
					}
					.colon {
						app.saved_cursor = app.logical_cursor
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
						delete_result := app.buffer.remove_char(app.logical_cursor.x,
							app.logical_cursor.y)
						if delete_result.joined_line {
							app.logical_cursor.move_up_buffer(app.buffer)
						}
						app.logical_cursor.move_to_x(app.buffer, delete_result.new_x)
						app.visual_cursor.update(app.buffer, mut app.logical_cursor)
					}
					.enter {
						app.buffer.insert_newline(app.logical_cursor.x, app.logical_cursor.y)
						app.logical_cursor.move_to_start_next_line_buffer(app.buffer)
						app.visual_cursor.update(app.buffer, mut app.logical_cursor)
					}
					else {
						app.buffer.insert_char(app.logical_cursor.x, app.logical_cursor.y,
							e.ascii.ascii_str())
						app.logical_cursor.move_right_buffer(app.buffer)
						app.visual_cursor.update(app.buffer, mut app.logical_cursor)
					}
				}
			}
			.command {
				match e.code {
					.enter {
						match app.cmd_buffer.command {
							'q' {
								app.cmd_buffer.command = ''
								exit(0)
							}
							else {}
						}
					}
					.escape {
						app.mode = .normal
						app.cmd_buffer.command = ''
						app.logical_cursor = app.saved_cursor
						app.visual_cursor.update(app.buffer, mut app.logical_cursor)
					}
					.backspace {
						app.cmd_buffer.remove_char(app.logical_cursor.x - 1)
					}
					else {
						ch := e.ascii.ascii_str()
						app.cmd_buffer.command += ch
					}
				}
			}
		}
	}
}
