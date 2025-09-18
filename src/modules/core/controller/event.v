module controller

import fs { read_file, write_file }
import time

pub fn event_loop(input UserInput, x voidptr) {
	mut app := get_app(x)

	// mut buf := app.buffers[app.active_buffer]

	event := input.e
	code := input.code

	if event == .key_down {
		match app.mode {
			.normal {
				match code {
					.l, .right {
						app.buffers[app.active_buffer].logical_cursor.move_right_buffer(app.buffers[app.active_buffer].lines)
						app.buffers[app.active_buffer].visual_cursor.x, app.buffers[app.active_buffer].visual_cursor.y = app.buffers[app.active_buffer].get_visual_coords(app.buffers[app.active_buffer].logical_cursor.x,
							app.buffers[app.active_buffer].logical_cursor.y, app.viewport.width)
						app.buffers[app.active_buffer].logical_cursor.update_desired_col(app.buffers[app.active_buffer].visual_cursor.x,
							app.viewport.width)
					}
					.h, .left {
						app.buffers[app.active_buffer].logical_cursor.move_left_buffer(app.buffers[app.active_buffer].lines)
						app.buffers[app.active_buffer].visual_cursor.x, app.buffers[app.active_buffer].visual_cursor.y = app.buffers[app.active_buffer].get_visual_coords(app.buffers[app.active_buffer].logical_cursor.x,
							app.buffers[app.active_buffer].logical_cursor.y, app.viewport.width)
						app.buffers[app.active_buffer].logical_cursor.update_desired_col(app.buffers[app.active_buffer].visual_cursor.x,
							app.viewport.width)
					}
					.j, .down {
						line := app.buffers[app.active_buffer].lines[app.buffers[app.active_buffer].logical_cursor.y]
						// ch := line[app.buffers[app.active_buffer].logical_cursor.x]
						// can't figure out accounting for tab width
						// mut char_width := 1
						// if ch == `\t` {
						// 	char_width = app.buffers[app.active_buffer].tabsize - (visual_col % app.buffer[app.active_buffer].tabsize)
						// }

						wrap_points := app.viewport.build_wrap_points(line)
						if wrap_points.len > 1
							&& app.buffers[app.active_buffer].logical_cursor.x < wrap_points[wrap_points.len - 1] {
							new_width := app.buffers[app.active_buffer].logical_cursor.x +
								app.viewport.width - 1
							if app.buffers[app.active_buffer].logical_cursor.desired_col > new_width {
								app.buffers[app.active_buffer].logical_cursor.x = app.buffers[app.active_buffer].logical_cursor.desired_col
							} else {
								app.buffers[app.active_buffer].logical_cursor.x = new_width
							}
						} else {
							app.buffers[app.active_buffer].logical_cursor.move_down_buffer(app.buffers[app.active_buffer].lines,
								app.buffers[app.active_buffer].logical_x)
						}
						app.buffers[app.active_buffer].visual_cursor.x, app.buffers[app.active_buffer].visual_cursor.y = app.buffers[app.active_buffer].get_visual_coords(app.buffers[app.active_buffer].logical_cursor.x,
							app.buffers[app.active_buffer].logical_cursor.y, app.viewport.width)

						// update offset
						app.viewport.update_offset(app.buffers[app.active_buffer].visual_cursor.y)
					}
					.k, .up {
						line := app.buffers[app.active_buffer].lines[app.buffers[app.active_buffer].logical_cursor.y]
						wrap_points := app.viewport.build_wrap_points(line)
						if wrap_points.len > 1
							&& app.buffers[app.active_buffer].logical_cursor.x > wrap_points[1] {
							new_width := app.buffers[app.active_buffer].logical_cursor.x - app.viewport.width
							if app.buffers[app.active_buffer].logical_cursor.desired_col < new_width {
								app.buffers[app.active_buffer].logical_cursor.x = app.buffers[app.active_buffer].logical_cursor.desired_col
							} else {
								app.buffers[app.active_buffer].logical_cursor.x = new_width
							}
						} else {
							app.buffers[app.active_buffer].logical_cursor.move_up_buffer(app.buffers[app.active_buffer].logical_x)
						}
						app.buffers[app.active_buffer].visual_cursor.x, app.buffers[app.active_buffer].visual_cursor.y = app.buffers[app.active_buffer].get_visual_coords(app.buffers[app.active_buffer].logical_cursor.x,
							app.buffers[app.active_buffer].logical_cursor.y, app.viewport.width)
						// update offset
						app.viewport.update_offset(app.buffers[app.active_buffer].visual_cursor.y)
					}
					.i {
						app.mode = .insert
					}
					.colon {
						app.buffers[app.active_buffer].saved_cursor = app.buffers[app.active_buffer].logical_cursor
						app.mode = .command
					}
					.tab {
						if app.buffers[app.active_buffer].is_directory_buffer {
							path := app.buffers[app.active_buffer].lines[app.buffers[app.active_buffer].logical_cursor.y]

							if fs.is_dir(app.buffers[app.active_buffer].path + path) {
								parent_dir, paths := fs.get_paths_from_dir(app.buffers[app.active_buffer].path,
									path)
								app.buffers[app.active_buffer].path = parent_dir
								app.buffers[app.active_buffer].lines = paths

								app.buffers[app.active_buffer].logical_cursor.x = 0
								app.buffers[app.active_buffer].logical_cursor.y = 0
								app.buffers[app.active_buffer].visual_cursor.x, app.buffers[app.active_buffer].visual_cursor.y = app.buffers[app.active_buffer].get_visual_coords(app.buffers[app.active_buffer].logical_cursor.x,
									app.buffers[app.active_buffer].logical_cursor.y, app.viewport.width)
								app.buffers[app.active_buffer].logical_cursor.update_desired_col(app.buffers[app.active_buffer].visual_cursor.x,
									app.viewport.width)
							}
						}
					}
					.backspace {
						if app.buffers[app.active_buffer].is_directory_buffer {
							parent_dir, paths := fs.get_paths_from_parent_dir(app.buffers[app.active_buffer].path)
							app.buffers[app.active_buffer].path = parent_dir
							app.buffers[app.active_buffer].lines = paths

							app.buffers[app.active_buffer].logical_cursor.x = 0
							app.buffers[app.active_buffer].logical_cursor.y = 0
							app.buffers[app.active_buffer].visual_cursor.x, app.buffers[app.active_buffer].visual_cursor.y = app.buffers[app.active_buffer].get_visual_coords(app.buffers[app.active_buffer].logical_cursor.x,
								app.buffers[app.active_buffer].logical_cursor.y, app.viewport.width)
							app.buffers[app.active_buffer].logical_cursor.update_desired_col(app.buffers[app.active_buffer].visual_cursor.x,
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
						delete_result := app.buffers[app.active_buffer].remove_char(app.buffers[app.active_buffer].logical_cursor.x,
							app.buffers[app.active_buffer].logical_cursor.y)
						if delete_result.joined_line {
							app.buffers[app.active_buffer].logical_cursor.move_up_buffer(app.buffers[app.active_buffer].logical_x)
						}
						app.buffers[app.active_buffer].logical_cursor.move_to_x(delete_result.new_x)
						app.buffers[app.active_buffer].visual_cursor.x, app.buffers[app.active_buffer].visual_cursor.y = app.buffers[app.active_buffer].get_visual_coords(app.buffers[app.active_buffer].logical_cursor.x,
							app.buffers[app.active_buffer].logical_cursor.y, app.viewport.width)
						app.buffers[app.active_buffer].logical_cursor.update_desired_col(app.buffers[app.active_buffer].visual_cursor.x,
							app.viewport.width)
					}
					.enter {
						app.buffers[app.active_buffer].insert_newline(app.buffers[app.active_buffer].logical_cursor.x,
							app.buffers[app.active_buffer].logical_cursor.y)
						app.buffers[app.active_buffer].logical_cursor.move_to_start_next_line_buffer(app.buffers[app.active_buffer].lines,
							app.buffers[app.active_buffer].logical_x)
						app.buffers[app.active_buffer].visual_cursor.x, app.buffers[app.active_buffer].visual_cursor.y = app.buffers[app.active_buffer].get_visual_coords(app.buffers[app.active_buffer].logical_cursor.x,
							app.buffers[app.active_buffer].logical_cursor.y, app.viewport.width)

						app.buffers[app.active_buffer].logical_cursor.update_desired_col(app.buffers[app.active_buffer].visual_cursor.x,
							app.viewport.width)
					}
					else {
						app.buffers[app.active_buffer].insert_char(app.buffers[app.active_buffer].logical_cursor.x,
							app.buffers[app.active_buffer].logical_cursor.y, u8(code).ascii_str())

						app.buffers[app.active_buffer].logical_cursor.move_right_buffer(app.buffers[app.active_buffer].lines)
						app.buffers[app.active_buffer].visual_cursor.x, app.buffers[app.active_buffer].visual_cursor.y = app.buffers[app.active_buffer].get_visual_coords(app.buffers[app.active_buffer].logical_cursor.x,
							app.buffers[app.active_buffer].logical_cursor.y, app.viewport.width)
						app.buffers[app.active_buffer].logical_cursor.update_desired_col(app.buffers[app.active_buffer].visual_cursor.x,
							app.viewport.width)
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
								result, message := write_file(app.buffers[app.active_buffer].path,
									app.buffers[app.active_buffer].lines)
								if result {
									// do something
									_ := message
								} else {
									app.buffers[app.active_buffer].lines = read_file(app.buffers[app.active_buffer].path) or {
										['']
									}
									// app.buffers[app.active_buffer].update_all_line_cache()
								}
								app.cmd_buffer.command = ''
								app.mode = .normal
								app.buffers[app.active_buffer].logical_cursor = app.buffers[app.active_buffer].saved_cursor
								app.buffers[app.active_buffer].visual_cursor.x, app.buffers[app.active_buffer].visual_cursor.y = app.buffers[app.active_buffer].get_visual_coords(app.buffers[app.active_buffer].logical_cursor.x,
									app.buffers[app.active_buffer].logical_cursor.y, app.viewport.width)
							}
							'cd' {
								app.add_directory_buffer()
								app.mode = .normal
								app.cmd_buffer.command = ''
								app.viewport.row_offset = 0
								app.buffers[app.active_buffer].logical_cursor = app.buffers[app.active_buffer].saved_cursor
								app.buffers[app.active_buffer].visual_cursor.x, app.buffers[app.active_buffer].visual_cursor.y = app.buffers[app.active_buffer].get_visual_coords(app.buffers[app.active_buffer].logical_cursor.x,
									app.buffers[app.active_buffer].logical_cursor.y, app.viewport.width)
							}
							'cb' {
								app.close_buffer()
								app.mode = .normal
								app.cmd_buffer.command = ''
								app.buffers[app.active_buffer].logical_cursor = app.buffers[app.active_buffer].saved_cursor
								app.buffers[app.active_buffer].visual_cursor.x, app.buffers[app.active_buffer].visual_cursor.y = app.buffers[app.active_buffer].get_visual_coords(app.buffers[app.active_buffer].logical_cursor.x,
									app.buffers[app.active_buffer].logical_cursor.y, app.viewport.width)
							}
							'doctor' {
								if app.stats.len == 0 {
									go fn [mut app] () {
										temp := app.buffers[app.active_buffer].path
										app.buffers[app.active_buffer].path = 'Error: Stats not available'
										time.sleep(2 * time.second)
										app.buffers[app.active_buffer].path = temp
									}()
									return
								}
								app.add_stats_buffer()
								app.mode = .normal
								app.cmd_buffer.command = ''
								app.viewport.row_offset = 0
								app.buffers[app.active_buffer].logical_cursor = app.buffers[app.active_buffer].saved_cursor
								app.buffers[app.active_buffer].visual_cursor.x, app.buffers[app.active_buffer].visual_cursor.y = app.buffers[app.active_buffer].get_visual_coords(app.buffers[app.active_buffer].logical_cursor.x,
									app.buffers[app.active_buffer].logical_cursor.y, app.viewport.width)
							}
							else {}
						}
					}
					.escape {
						app.mode = .normal
						app.cmd_buffer.command = ''
						app.buffers[app.active_buffer].logical_cursor = app.buffers[app.active_buffer].saved_cursor
						app.buffers[app.active_buffer].visual_cursor.x, app.buffers[app.active_buffer].visual_cursor.y = app.buffers[app.active_buffer].get_visual_coords(app.buffers[app.active_buffer].logical_cursor.x,
							app.buffers[app.active_buffer].logical_cursor.y, app.viewport.width)
					}
					.backspace {
						// // command string start at x = 2
						// command_str_index := app.buffers[app.active_buffer].logical_cursor.x - 2
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
