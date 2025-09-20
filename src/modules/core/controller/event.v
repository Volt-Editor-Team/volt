module controller

import fs { read_file, write_file }
import time

pub fn event_loop(input UserInput, x voidptr) {
	mut app := get_app(x)

	mut buf := &app.buffers[app.active_buffer]

	event := input.e
	code := input.code

	if event == .key_down {
		match app.mode {
			.normal {
				match code {
					.l, .right {
						buf.logical_cursor.move_right_buffer(buf.lines)
						buf.update_visual_cursor(app.viewport.width)
						buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
					}
					.h, .left {
						buf.logical_cursor.move_left_buffer(buf.lines)
						buf.update_visual_cursor(app.viewport.width)
						buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
					}
					.j, .down {
						line := buf.lines[buf.logical_cursor.y]
						// ch := line[buf.logical_cursor.x]
						// can't figure out accounting for tab width
						// mut char_width := 1
						// if ch == `\t` {
						// 	char_width = buf.tabsize - (visual_col % app.buffer[app.active_buffer].tabsize)
						// }

						wrap_points := app.viewport.build_wrap_points(line)
						if wrap_points.len > 1
							&& buf.logical_cursor.x < wrap_points[wrap_points.len - 1] {
							new_width := buf.logical_cursor.x + app.viewport.width - 1
							if buf.logical_cursor.desired_col > new_width {
								buf.logical_cursor.x = buf.logical_cursor.desired_col
							} else {
								buf.logical_cursor.x = new_width
							}
						} else {
							buf.logical_cursor.move_down_buffer(buf.lines, buf.logical_x)
						}
						buf.update_visual_cursor(app.viewport.width)

						// update offset
						app.viewport.update_offset(buf.visual_cursor.y)
					}
					.k, .up {
						line := buf.lines[buf.logical_cursor.y]
						wrap_points := app.viewport.build_wrap_points(line)
						if wrap_points.len > 1 && buf.logical_cursor.x > wrap_points[1] {
							new_width := buf.logical_cursor.x - app.viewport.width
							if buf.logical_cursor.desired_col < new_width {
								buf.logical_cursor.x = buf.logical_cursor.desired_col
							} else {
								buf.logical_cursor.x = new_width
							}
						} else {
							buf.logical_cursor.move_up_buffer(buf.logical_x)
						}
						buf.update_visual_cursor(app.viewport.width)
						// update offset
						app.viewport.update_offset(buf.visual_cursor.y)
					}
					.i {
						app.mode = .insert
					}
					.colon {
						buf.saved_cursor = buf.logical_cursor
						app.mode = .command
					}
					.tab {
						if buf.is_directory_buffer {
							path := buf.lines[buf.logical_cursor.y]

							if fs.is_dir(buf.path + path) {
								parent_dir, paths := fs.get_paths_from_dir(buf.path, path)
								buf.path = parent_dir
								buf.lines = paths

								buf.logical_cursor.x = 0
								buf.logical_cursor.y = 0
								buf.update_visual_cursor(app.viewport.width)
								buf.logical_cursor.update_desired_col(buf.visual_cursor.x,
									app.viewport.width)
							}
						}
					}
					.backspace {
						if buf.is_directory_buffer {
							parent_dir, paths := fs.get_paths_from_parent_dir(buf.path)
							buf.path = parent_dir
							buf.lines = paths

							buf.logical_cursor.x = 0
							buf.logical_cursor.y = 0
							buf.update_visual_cursor(app.viewport.width)
							buf.logical_cursor.update_desired_col(buf.visual_cursor.x,
								app.viewport.width)
						}
					}
					// next two key bindings are bad. using them for testing
					.b {
						if app.buffers.len > 1 {
							if app.active_buffer == 0 {
								app.active_buffer = app.buffers.len - 1
							} else {
								app.active_buffer -= 1
							}
						}
					}
					.n {
						if app.buffers.len > 1 {
							if app.active_buffer == app.buffers.len - 1 {
								app.active_buffer = 0
							} else {
								app.active_buffer += 1
							}
						}
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
						delete_result := buf.remove_char(buf.logical_cursor.x, buf.logical_cursor.y)
						if delete_result.joined_line {
							buf.logical_cursor.move_up_buffer(buf.logical_x)
						}
						buf.logical_cursor.move_to_x(delete_result.new_x)
						buf.update_visual_cursor(app.viewport.width)
						buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
					}
					.enter {
						buf.insert_newline(buf.logical_cursor.x, buf.logical_cursor.y)
						buf.logical_cursor.move_to_start_next_line_buffer(buf.lines, buf.logical_x)
						buf.update_visual_cursor(app.viewport.width)

						buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
					}
					else {
						buf.insert_char(buf.logical_cursor.x, buf.logical_cursor.y, u8(code).ascii_str())

						buf.logical_cursor.move_right_buffer(buf.lines)
						buf.update_visual_cursor(app.viewport.width)
						buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
					}
				}
			}
			.command {
				cmd_str := app.cmd_buffer.command
				match code {
					.enter {
						match cmd_str {
							'q', 'quit' {
								app.cmd_buffer.command = ''
								exit(0)
							}
							'w', 'write' {
								result, message := write_file(buf.path, buf.lines)
								if result {
									// do something
									_ := message
								} else {
									buf.lines = read_file(buf.path) or { [''] }
									// buf.update_all_line_cache()
								}
								app.cmd_buffer.command = ''
								app.mode = .normal
								buf.logical_cursor = buf.saved_cursor
								buf.update_visual_cursor(app.viewport.width)
							}
							'cd' {
								app.add_directory_buffer()
								app.mode = .normal
								app.cmd_buffer.command = ''
								app.viewport.row_offset = 0
								buf.logical_cursor = buf.saved_cursor
								buf.update_visual_cursor(app.viewport.width)
							}
							'cb' {
								app.close_buffer()
								app.mode = .normal
								app.cmd_buffer.command = ''
								buf.logical_cursor = buf.saved_cursor
								buf.update_visual_cursor(app.viewport.width)
							}
							'doctor' {
								if app.stats.len == 0 {
									go fn [mut buf] () {
										temp := buf.path
										buf.path = 'Error: Stats not available'
										time.sleep(2 * time.second)
										buf.path = temp
									}()
									return
								}
								app.add_stats_buffer()
								app.mode = .normal
								app.cmd_buffer.command = ''
								app.viewport.row_offset = 0
								buf.logical_cursor = buf.saved_cursor
								buf.update_visual_cursor(app.viewport.width)
							}
							else {}
						}
					}
					.escape {
						app.mode = .normal
						app.cmd_buffer.command = ''
						buf.logical_cursor = buf.saved_cursor
						buf.update_visual_cursor(app.viewport.width)
					}
					.backspace {
						// // command string start at x = 2
						// command_str_index := buf.logical_cursor.x - 2
						// remove char before index
						if app.cmd_buffer.command.len > 0 {
							app.cmd_buffer.remove_char(app.cmd_buffer.command.len - 1)
						}
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
