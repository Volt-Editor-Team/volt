module controller

import os
import math

pub fn handle_insert_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	// global normal mode
	if event == .key_down {
		match key {
			.escape {
				// not for temporary buffers
				if buf.p_mode != .fuzzy || buf.p_mode != .directory {
					buf.prev_mode = buf.mode
				}
				if buf.p_mode == .fuzzy {
					buf.temp_cursor.y = math.min(buf.temp_data.len - 1, buf.temp_cursor.y)
				}
				buf.mode = .normal
				return
			}
			else {}
		}
	}
	// specific to persistant mode
	match buf.p_mode {
		.default, .directory {
			if event == .key_down {
				if buf.mode != .command {
					match key {
						.backspace {
							prev_line_len := if buf.logical_cursor.y > 0 {
								buf.buffer.line_at(buf.logical_cursor.y - 1).len
							} else {
								0
							}
							total_lines := buf.buffer.line_count()
							buf.buffer.delete(buf.logical_cursor.flat_index - 1, 1) or { return }
							buf.cur_line = buf.buffer.line_at(buf.logical_cursor.y)
							// delete_result := buf.remove_char(buf.logical_cursor.x, buf.logical_cursor.y)
							if buf.buffer.line_count() != total_lines {
								buf.logical_cursor.flat_index += buf.buffer.line_at(buf.logical_cursor.y - 1).len - prev_line_len
								buf.logical_cursor.move_up_buffer(mut buf.cur_line, buf.buffer,
									buf.tabsize)
								buf.logical_cursor.move_to_x(buf.cur_line, prev_line_len,
									buf.tabsize)
							} else {
								if buf.logical_cursor.x > 0 {
									buf.logical_cursor.move_to_x(buf.cur_line, buf.logical_cursor.x - 1,
										buf.tabsize)
								}
							}
							buf.logical_cursor.update_desired_col(app.viewport.width)
						}
						.enter {
							mut previous_indentation := []rune{}
							previous_indentation << `\n`
							for ch in buf.cur_line {
								if !ch.str().is_blank() {
									break
								} else {
									previous_indentation << ch
								}
							}

							buf.buffer.insert(buf.logical_cursor.flat_index, previous_indentation) or {
								return
							}
							buf.logical_cursor.move_to_x_next_line_buffer(previous_indentation.len - 1, mut
								buf.cur_line, buf.buffer, buf.tabsize)
							buf.logical_cursor.update_desired_col(app.viewport.width)
						}
						else {
							mut ch := rune(int(key))
							if mod == .shift {
								ch = ch.to_upper()
							}

							buf.buffer.insert(buf.logical_cursor.flat_index, ch) or { return }
							buf.cur_line = buf.buffer.line_at(buf.logical_cursor.y)

							buf.logical_cursor.move_right_buffer(mut buf.cur_line, buf.buffer,
								buf.tabsize)
							buf.logical_cursor.update_desired_col(app.viewport.width)
						}
					}
				}
			}
		}
		.fuzzy {
			if event == .key_down {
				match mod {
					.shift {
						match key {
							.enter {}
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
					.ctrl {
						match key {
							.q {
								// restore settings
								// buf.path = buf.temp_path
								buf.p_mode = buf.temp_mode
								buf.mode = .normal
								// buf.logical_cursor = buf.temp_cursor
								buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
									app.viewport.margin)

								// delete temp stuff
								buf.temp_label = ''
								buf.temp_data.clear()
								buf.file_ch.close()
							}
							else {}
						}
					}
					else {
						match key {
							// for switch fuzzy search directory
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
							.comma {
								if buf.temp_data.len > 0 {
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
									buf.temp_list.clear()
									buf.temp_label = ''
									buf.temp_int = 0
									buf.temp_data.clear()
									buf.menu_state = false
								}
							}
							.backspace {
								if buf.temp_label.len > 0 {
									buf.temp_label = buf.temp_label[..buf.temp_label.len - 1]
								}
							}
							.colon {
								buf.saved_cursor = buf.logical_cursor
								buf.mode = .command
							}
							else {
								buf.temp_label += rune(int(key)).str()
								if buf.temp_cursor.y > buf.temp_data.len {
									buf.temp_cursor.y = 0
									buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
										app.viewport.margin)
								}
							}
						}
					}
				}
			}
		}
	}
}
