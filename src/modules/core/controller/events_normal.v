module controller

import fs
import os
import util
import math

pub fn handle_normal_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	// global normal mode
	if event == .key_down {
		if mod == .alt && key == .m {
			buf.menu_state = !buf.menu_state
			return
		}
		if app.cmd_buffer.command.len > 0 {
			app.cmd_buffer.command = ''
		}
		match key {
			.f {
				buf.prev_mode = buf.mode
				buf.mode = .search
				buf.menu_state = true
			}
			.space {
				buf.prev_mode = buf.mode
				buf.mode = .menu
				buf.menu_state = true
			}
			.g {
				buf.prev_mode = buf.mode
				buf.mode = .goto
				buf.menu_state = true
			}
			.i {
				buf.prev_mode = buf.mode
				buf.mode = .insert
				buf.menu_state = false
			}
			.colon {
				buf.prev_mode = buf.mode
				buf.saved_cursor = buf.logical_cursor
				buf.mode = .command
				app.cmd_buffer.command = ': '
				buf.menu_state = false
			}
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

	// specific to persistant mode
	if buf.p_mode == .default || buf.p_mode == .directory {
		if event == .key_down {
			match key {
				.d {
					// currently just deletes one character
					// will need to be changed when selections are supported
					buf.buffer.delete(buf.logical_cursor.flat_index, 1) or { return }
					buf.cur_line = buf.buffer.line_at(buf.logical_cursor.y)
				}
				.l, .right {
					prev_y := buf.logical_cursor.y
					buf.logical_cursor.move_right_buffer(mut buf.cur_line, buf.buffer,
						buf.tabsize)
					buf.logical_cursor.update_desired_col(app.viewport.width)

					if buf.logical_cursor.y != prev_y {
						buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
							app.viewport.margin)
					}
				}
				.h, .left {
					prev_y := buf.logical_cursor.y
					buf.logical_cursor.move_left_buffer(mut buf.cur_line, buf.buffer,
						buf.tabsize)
					buf.logical_cursor.update_desired_col(app.viewport.width)
					if buf.logical_cursor.y != prev_y {
						buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
							app.viewport.margin)
					}
				}
				.j, .down {
					line := buf.cur_line

					// total wraps in the current line
					mut total_wraps := 0
					if line.len != 0 {
						total_wraps = util.char_count_expanded_tabs(line, buf.tabsize) / app.viewport.width
					}

					// current wrap index
					cur_wrap := buf.logical_cursor.visual_x / app.viewport.width

					if cur_wrap < total_wraps {
						mut perfect_index := util.expand_tabs_to(line#[..buf.logical_cursor.x +
							app.viewport.width - 1], buf.logical_cursor.x + app.viewport.width - 1,
							buf.tabsize)
						if buf.logical_cursor.x + app.viewport.width - 1 <= line.len {
							perfect_index++
						}
						buf.logical_cursor.move_to_x(buf.cur_line, perfect_index, buf.tabsize)
					} else {
						buf.logical_cursor.move_down_buffer(mut buf.cur_line, buf.buffer,
							buf.tabsize)
					}

					// update viewport offset
					buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
						app.viewport.margin)
				}
				.k, .up {
					cur_wrap := util.char_count_expanded_tabs(buf.buffer.line_at(buf.logical_cursor.y)#[..buf.logical_cursor.x],
						buf.tabsize) / app.viewport.width
					if cur_wrap == 0 {
						// line above is NOT the first line
						if buf.logical_cursor.y - 1 > 0 {
							line := buf.buffer.line_at(buf.logical_cursor.y - 1)

							mut total_wraps := 0
							if line.len != 0 {
								total_wraps = util.char_count_expanded_tabs(line, buf.tabsize) / app.viewport.width
							}
							if total_wraps > 0 {
								buf.logical_cursor.move_up_buffer(mut buf.cur_line, buf.buffer,
									buf.tabsize)
								mut index := total_wraps * app.viewport.width + buf.logical_cursor.x
								perfect_index := util.expand_tabs_to(line#[..index - 1],
									index - 1, buf.tabsize)
								buf.logical_cursor.move_to_x(buf.cur_line, perfect_index,
									buf.tabsize)
							} else {
								buf.logical_cursor.move_up_buffer(mut buf.cur_line, buf.buffer,
									buf.tabsize)
							}
						} else {
							buf.logical_cursor.move_up_buffer(mut buf.cur_line, buf.buffer,
								buf.tabsize)
						}
					} else {
						line := buf.buffer.line_at(buf.logical_cursor.y)
						index := math.max(cur_wrap * app.viewport.width +
							buf.logical_cursor.desired_col, buf.logical_cursor.x)
						next_index := util.expand_tabs_to(line#[..index - app.viewport.width - 1],
							index - app.viewport.width - 1, buf.tabsize)
						buf.logical_cursor.move_to_x(buf.cur_line, math.min(next_index,
							buf.logical_cursor.desired_col), buf.tabsize)
					}

					// update offset
					buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
						app.viewport.margin)
				}
				else {}
			}
		}
	}
	match buf.p_mode {
		.directory {
			match mod {
				.none {
					match key {
						.enter {
							path := buf.buffer.line_at(buf.logical_cursor.y).string()
							app.add_new_buffer(
								name:    os.file_name(path)
								path:    buf.path + path
								tabsize: buf.tabsize
								type:    .gap
								mode:    .normal
								p_mode:  .default
							)
						}
						.tab {
							path := buf.buffer.line_at(buf.logical_cursor.y).string()

							if fs.is_dir(buf.path + path) {
								parent_dir, paths := fs.get_paths_from_dir(buf.path, path)
								buf.path = parent_dir
								replacement_runes := [][]rune{len: paths.len, init: paths[index].runes()}
								buf.buffer.replace_with_temp(replacement_runes)

								buf.logical_cursor.x = 0
								buf.logical_cursor.y = 0
								buf.logical_cursor.flat_index = 0
							}
						}
						.backspace {
							parent_dir, paths := fs.get_paths_from_parent_dir(buf.path)
							buf.path = parent_dir
							replacement_runes := [][]rune{len: paths.len, init: paths[index].runes()}
							buf.buffer.replace_with_temp(replacement_runes)

							buf.logical_cursor.x = 0
							buf.logical_cursor.y = 0
							buf.logical_cursor.flat_index = 0
						}
						else {}
					}
				}
				else {}
			}
		}
		.fuzzy {
			match mod {
				.none {
					match key {
						.escape {
							// restore settings
							// buf.path = buf.temp_path
							buf.p_mode = buf.temp_mode
							buf.mode = .normal
							buf.logical_cursor = buf.temp_cursor
							buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
								app.viewport.margin)

							// delete temp stuff
							buf.temp_label = ''
							buf.temp_data.clear()
							buf.file_ch.close()
							buf.menu_state = false
						}
						.j, .down {
							if buf.logical_cursor.y < buf.temp_data.len - 1 {
								buf.logical_cursor.y++
								buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
									app.viewport.margin)
							}
						}
						.k, .up {
							if buf.logical_cursor.y > 0 {
								buf.logical_cursor.y--
								buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
									app.viewport.margin)
							}
						}
						// for switch fuzzy search directory
						.tab {
							if buf.temp_data.len > 0 {
								if buf.temp_fuzzy_type == .dir {
									file := buf.temp_data[buf.logical_cursor.y].string()

									buf.temp_path += os.path_separator + file

									if os.is_dir(buf.temp_path) {
										// delete temp stuff
										buf.temp_label = ''
										buf.temp_data.clear()
										buf.file_ch.close()
										buf.p_mode = buf.temp_mode
										// reset and open fuzzy
										buf.open_fuzzy_find(buf.temp_path, .directory)
									}
								}
							}
						}
						.o {
							if buf.temp_data.len > 0 {
								if buf.temp_fuzzy_type == .dir {
									file := buf.temp_data[buf.logical_cursor.y].string()

									buf.temp_path += os.path_separator + file

									if os.is_dir(buf.temp_path) {
										// delete temp stuff
										buf.temp_label = ''
										buf.temp_int = 0
										buf.temp_data.clear()
										buf.file_ch.close()
										// reset and open fuzzy
										buf.p_mode = buf.temp_mode
										buf.temp_fuzzy_type = .file
										buf.open_fuzzy_find(buf.temp_path, .file)
									}
								}
							}
						}
						.enter {
							if buf.temp_data.len > 0 {
								file := buf.temp_data[buf.logical_cursor.y].string()

								// buf.path = buf.temp_path
								buf.p_mode = buf.temp_mode
								buf.mode = .normal
								buf.logical_cursor = buf.temp_cursor
								buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
									app.viewport.margin)
								buf.file_ch.close()

								// delete temp stuff
								mut path := buf.temp_path + os.path_separator + file

								if os.is_dir(path) {
									dir_path := path + os.path_separator
									for mut buffer in app.buffers {
										full_path := app.working_dir + os.path_separator +
											buffer.path
										if full_path.starts_with(dir_path) {
											buffer.path = full_path.replace(dir_path,
												'')
										} else {
											buffer.path = full_path
										}
									}
									os.chdir(path) or { return }
									app.working_dir = path
								} else {
									app.add_new_buffer(
										name:    os.file_name(file)
										path:    path
										tabsize: buf.tabsize
										type:    .list
										mode:    .normal
										p_mode:  .default
									)
									if path.starts_with(app.working_dir + os.path_separator) {
										app.buffers[app.active_buffer].path = path.replace(
											app.working_dir + os.path_separator, '')
									}
								}
								buf.temp_label = ''
								buf.temp_int = 0
								buf.temp_data.clear()
								buf.menu_state = false
							}
						}
						else {}
					}
				}
				.shift {
					match key {
						// for switch fuzzy search directory
						.tab {
							// buf.path = buf.temp_path
							if buf.temp_fuzzy_type == .dir {
								buf.temp_path = os.dir(buf.temp_path)
								if os.is_dir(buf.temp_path) {
									// delete temp stuff
									buf.temp_label = ''
									buf.temp_int = 0
									buf.temp_data.clear()
									buf.file_ch.close()
									buf.p_mode = buf.temp_mode
									// reset and open fuzzy
									buf.open_fuzzy_find(buf.temp_path, .directory)
								}
							}
						}
						else {}
					}
				}
				else {}
			}
		}
		else {}
	}
}
