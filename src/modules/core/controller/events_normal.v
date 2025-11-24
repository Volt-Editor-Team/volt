module controller

import fs
import os
import util
import math

pub fn handle_normal_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	mut view := &app.viewport
	// global normal mode
	if event == .key_down {
		match app.os {
			'windows' {
				if mod == .ctrl && key == .m {
					buf.menu_state = !buf.menu_state
					return
				}
			}
			else {
				if mod == .alt && key == .m {
					buf.menu_state = !buf.menu_state
					return
				}
			}
		}
		if buf.cmd.command.len > 0 {
			buf.cmd.command = ''
		}
		match key {
			.f {
				buf.change_mode(.search, true)
			}
			.space {
				buf.change_mode(.menu, true)
			}
			.g {
				buf.change_mode(.goto, true)
			}
			.i {
				buf.change_mode(.insert, false)
			}
			.colon {
				buf.change_mode(.command, false)
			}
			.comma {
				if mod == .alt {
					if app.buffers.len > 1 {
						if app.active_buffer == 0 {
							app.active_buffer = app.buffers.len - 1
						} else {
							app.active_buffer -= 1
						}
						view.update_offset(app.buffers[app.active_buffer].logical_cursor.y)
					}
				}
			}
			.period {
				if mod == .alt {
					if app.buffers.len > 1 {
						if app.active_buffer == app.buffers.len - 1 {
							app.active_buffer = 0
						} else {
							app.active_buffer += 1
						}
						view.update_offset(app.buffers[app.active_buffer].logical_cursor.y)
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
					buf.delete(1)
				}
				.l, .right {
					prev_y := buf.logical_cursor.y
					buf.logical_cursor.move_right_buffer(mut buf.cur_line, buf.buffer, mut
						view.visible_lines, buf.tabsize)
					buf.logical_cursor.update_desired_col(app.viewport.width)

					if buf.logical_cursor.y != prev_y {
						view.update_offset(buf.logical_cursor.y)
					}
				}
				.h, .left {
					prev_y := buf.logical_cursor.y
					buf.logical_cursor.move_left_buffer(mut buf.cur_line, buf.buffer,
						buf.tabsize)
					buf.logical_cursor.update_desired_col(app.viewport.width)
					if buf.logical_cursor.y != prev_y {
						view.update_offset(buf.logical_cursor.y)
						// buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
						// 	app.viewport.margin, app.viewport.row_offset)
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
					view.update_offset(buf.logical_cursor.y)
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
					view.update_offset(buf.logical_cursor.y)
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
							buf.p_mode = buf.temp_mode
							buf.change_mode(.normal, false)
							view.update_offset(buf.logical_cursor.y)

							// delete temp stuff
							// buf.temp_label = ''
							// buf.temp_data.clear()
							buf.clear_all_temp_data()
							buf.file_ch.close()
						}
						.j, .down {
							if buf.temp_cursor.y < buf.temp_data.len - 1 {
								buf.temp_cursor.y++
								view.update_offset(buf.logical_cursor.y)
							}
						}
						.k, .up {
							if buf.temp_cursor.y > 0 {
								buf.temp_cursor.y--
								view.update_offset(buf.logical_cursor.y)
							}
						}
						// for switch fuzzy search directory
						.tab {
							if buf.temp_data.len > 0 {
								file := buf.temp_data[buf.temp_cursor.y].string()

								path := buf.temp_path + os.path_separator + file

								if os.is_dir(path) {
									buf.temp_path = path
									// delete temp stuff
									buf.temp_label = ''
									buf.temp_data.clear()
									buf.file_ch.close()
									buf.p_mode = buf.temp_mode
									buf.temp_fuzzy_type = .dir
									// reset and open fuzzy
									buf.open_fuzzy_find(buf.temp_path, .directory)
								}
							}
						}
						.backtick {
							if buf.temp_fuzzy_type == .dir {
								buf.temp_label = ''
								buf.temp_data.clear()
								buf.file_ch.close()
								buf.p_mode = buf.temp_mode
								buf.temp_fuzzy_type = .file
								// reset and open fuzzy
								buf.open_fuzzy_find(buf.temp_path, .file)
							} else if buf.temp_fuzzy_type == .file {
								buf.temp_label = ''
								buf.temp_data.clear()
								buf.file_ch.close()
								buf.p_mode = buf.temp_mode
								buf.temp_fuzzy_type = .dir
								// reset and open fuzzy
								buf.open_fuzzy_find(buf.temp_path, .directory)
							}
						}
						.o {
							if buf.temp_data.len > 0 {
								file := buf.temp_data[buf.temp_cursor.y].string()

								path := buf.temp_path + os.path_separator + file

								if os.is_dir(path) {
									buf.temp_path = path
									// delete temp stuff
									buf.temp_label = ''
									buf.temp_int = 0
									buf.temp_data.clear()
									buf.file_ch.close()
									buf.temp_cursor.y = 0
									// reset and open fuzzy
									buf.p_mode = buf.temp_mode
									buf.temp_fuzzy_type = .file
									buf.open_fuzzy_find(buf.temp_path, .file)
								}
							}
						}
						.comma {
							if buf.temp_data.len > 0 {
								if buf.temp_cursor.y < 0
									|| buf.temp_cursor.y > buf.temp_data.len - 1 {
									buf.temp_cursor.y = math.min(buf.temp_data.len - 1,
										buf.temp_cursor.y)
								}
								file := buf.temp_data[buf.temp_cursor.y].string()
								mut path := buf.temp_path + os.path_separator + file

								if os.is_file(path) {
									if buf.temp_list.contains(path) {
										mut index := 0
										for p in buf.temp_list {
											if p == path {
												break
											}
											index++
										}
										buf.temp_list.delete(index)
									} else {
										buf.temp_list << path
									}
									buf.temp_label = ''
								}
							}
						}
						.enter {
							if buf.temp_data.len > 0 {
								file := buf.temp_data[buf.temp_cursor.y].string()

								// buf.path = buf.temp_path
								buf.p_mode = buf.temp_mode
								buf.mode = .normal
								// buf.logical_cursor = buf.temp_cursor
								view.update_offset(buf.logical_cursor.y)
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
									if buf.temp_list.len == 0 {
										buf.temp_list << path
									}
								}
								file_list := buf.temp_list.clone()
								tabsize := buf.tabsize

								for i, paths in file_list {
									if i == 0 {
										app.add_new_buffer(
											name:    os.file_name(paths)
											path:    paths
											tabsize: tabsize
											type:    .gap
											mode:    .normal
											p_mode:  .default
										)
									} else {
										app.append_new_buffer(
											name:    os.file_name(paths)
											path:    paths
											tabsize: tabsize
											type:    .gap
											mode:    .normal
											p_mode:  .default
										)
									}
								}
								app.active_buffer = app.buffers.len - 1
								buf.temp_list.clear()
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
							buf.temp_path = os.dir(buf.temp_path)
							if os.is_dir(buf.temp_path) {
								// delete temp stuff
								buf.temp_label = ''
								buf.temp_int = 0
								buf.temp_data.clear()
								buf.file_ch.close()
								buf.p_mode = buf.temp_mode
								buf.temp_fuzzy_type = .dir
								// reset and open fuzzy
								buf.open_fuzzy_find(buf.temp_path, .directory)
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
