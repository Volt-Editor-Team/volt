module controller

import io

pub fn event(input UserInput, x voidptr) {
	mut app := get_app(x)

	event := input.e
	code := input.code

	if event == .key_down {
		match app.mode {
			.normal {
				match code {
					.l {
						app.logical_cursor.move_right_buffer(app.buffer)
						app.visual_cursor.update(app.buffer, mut app.logical_cursor)
						app.logical_cursor.update_desired_col(app.visual_cursor.x, app.viewport.width)
					}
					.h {
						app.logical_cursor.move_left_buffer(app.buffer)
						app.visual_cursor.update(app.buffer, mut app.logical_cursor)
						app.logical_cursor.update_desired_col(app.visual_cursor.x, app.viewport.width)
					}
					.j {
						line := app.buffer.lines[app.logical_cursor.y]
						wrap_points := app.viewport.build_wrap_points(line)
						if wrap_points.len > 1
							&& app.logical_cursor.x < wrap_points[wrap_points.len - 1] {
							new_width := app.logical_cursor.x + app.viewport.width
							if app.logical_cursor.desired_col > new_width {
								app.logical_cursor.x = app.logical_cursor.desired_col
							} else {
								app.logical_cursor.x = new_width
							}
						} else {
							app.logical_cursor.move_down_buffer(app.buffer)
						}
						app.visual_cursor.update(app.buffer, mut app.logical_cursor)
						if app.viewport.update_offset(app.visual_cursor.y) {
							app.tui.reset()
						}
					}
					.k {
						line := app.buffer.lines[app.logical_cursor.y]
						wrap_points := app.viewport.build_wrap_points(line)
						if wrap_points.len > 1 && app.logical_cursor.x > wrap_points[1] {
							new_width := app.logical_cursor.x - app.viewport.width
							if app.logical_cursor.desired_col < new_width {
								app.logical_cursor.x = app.logical_cursor.desired_col
							} else {
								app.logical_cursor.x = new_width
							}
						} else {
							app.logical_cursor.move_up_buffer(app.buffer)
						}
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
				match code {
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
						app.logical_cursor.update_desired_col(app.visual_cursor.x, app.viewport.width)
					}
					.enter {
						app.buffer.insert_newline(app.logical_cursor.x, app.logical_cursor.y)
						app.logical_cursor.move_to_start_next_line_buffer(app.buffer)
						app.visual_cursor.update(app.buffer, mut app.logical_cursor)

						app.logical_cursor.update_desired_col(app.visual_cursor.x, app.viewport.width)
					}
					else {
						app.buffer.insert_char(app.logical_cursor.x, app.logical_cursor.y,
							u8(code).ascii_str())
						app.logical_cursor.move_right_buffer(app.buffer)
						app.visual_cursor.update(app.buffer, mut app.logical_cursor)
						app.logical_cursor.update_desired_col(app.visual_cursor.x, app.viewport.width)
					}
				}
			}
			.command {
				cmd_str := app.cmd_buffer.command
				match code {
					.enter {
						match true {
							cmd_str == 'q' || cmd_str == 'quit' {
								app.cmd_buffer.command = ''
								exit(0)
							}
							cmd_str == 'w' {
								did_write := io.write_file(app.buffer.path, app.buffer.lines)
								if !did_write {
									// do something
								} else {
									app.buffer.lines = io.read_file(app.buffer.path) or {
										['']
									}
									// app.buffer.update_all_line_cache()
								}
								app.cmd_buffer.command = ''
								app.mode = .normal
								app.logical_cursor = app.saved_cursor
								app.visual_cursor.update(app.buffer, mut app.logical_cursor)
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
						// command string start at x = 2
						command_str_index := app.logical_cursor.x - 2
						// remove char before index
						app.cmd_buffer.remove_char(command_str_index - 1)
					}
					else {
						ch := u8(code).ascii_str()
						app.cmd_buffer.command += ch
					}
				}
			}
		}
	}
}
