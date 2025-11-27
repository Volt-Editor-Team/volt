module controller

import os
import math
import time

pub fn handle_insert_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	mut view := &app.viewport
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
							total_lines := buf.buffer.line_count() // grab line_count to determine if a newline is deleted
							// take the previous lines length
							prev_line_len := if view.cursor.y > 0 {
								buf.buffer.line_at(view.cursor.y - 1).len
							} else {
								0
							}

							// delete the character before the cursor
							buf.buffer.delete(view.cursor.flat_index - 1, 1) or { return }
							// a line was deleted
							if buf.buffer.line_count() != total_lines {
								// move cursor
								view.cursor.move_up_buffer(view.visible_lines, view.row_offset,
									view.tabsize)
								updated_line := buf.buffer.line_at(view.cursor.y).clone()
								view.cursor.move_to_x(updated_line, prev_line_len, view.tabsize)
								view.visible_lines[view.cursor.y - view.row_offset] = updated_line

								// delete merged line
								view.visible_lines.delete(view.cursor.y - view.row_offset + 1)

								// add new line from data
								next_line := buf.buffer.line_at(view.row_offset +
									view.visible_lines.len).clone()
								view.visible_lines << next_line
							}
							// no line was deleted
							else {
								if view.cursor.x > 0 {
									// move cursor
									view.cursor.move_to_x(buf.cur_line, view.cursor.x - 1,
										view.tabsize)
									// update current visible line
									updated_line := buf.buffer.line_at(view.cursor.y).clone()
									view.visible_lines[view.cursor.y - view.row_offset] = updated_line
								}
							}
							view.update_offset(view.cursor.y, buf.buffer)
							// view.fill_visible_lines(buf.buffer)
							view.cursor.update_desired_col(app.viewport.width)
						}
						.enter {
							// adopt previous indentation
							mut previous_indentation := []rune{}
							previous_indentation << `\n`
							relative_y := view.cursor.y - view.row_offset
							for i, ch in buf.buffer.line_at(view.cursor.y) {
								if !ch.str().is_blank() || i == view.cursor.x {
									break
								} else {
									previous_indentation << ch
								}
							}

							// edit buffer data
							buf.buffer.insert(view.cursor.flat_index, previous_indentation) or {
								return
							}

							// update visible lines
							updated_line := buf.buffer.line_at(view.cursor.y).clone()
							view.visible_lines[relative_y] = updated_line
							next_line := buf.buffer.line_at(view.cursor.y + 1).clone()
							view.visible_lines.insert(relative_y + 1, next_line)

							// clamp visible buffer if it contains more than viewable lines
							if view.visible_lines.len >= view.height
								&& view.visible_lines.len + view.row_offset < buf.buffer.line_count() {
								view.visible_lines.delete_last()
							}

							// move cursor
							view.cursor.move_to_x_next_line_buffer(previous_indentation.len - 1,
								view.visible_lines, view.row_offset, view.tabsize)

							// update viewport offset
							view.update_offset(view.cursor.y, buf.buffer)

							// update desired column
							view.cursor.update_desired_col(app.viewport.width)
						}
						else {
							mut ch := rune(int(key))
							if mod == .shift {
								ch = ch.to_upper()
							}

							buf.buffer.insert(view.cursor.flat_index, ch) or { return }
							updated_line := buf.buffer.line_at(view.cursor.y).clone()
							view.visible_lines[view.cursor.y - view.row_offset] = updated_line

							// view.cursor.move_right_buffer(mut buf.cur_line, buf.buffer, mut
							// 	view.visible_lines, view.tabsize)
							view.cursor.move_right_buffer(view.visible_lines, view.row_offset,
								view.tabsize)
							view.cursor.update_desired_col(app.viewport.width)
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
							.colon {
								buf.prev_mode = buf.mode
								// buf.saved_cursor = view.cursor
								buf.mode = .command
								buf.cmd.command = ': '
								buf.menu_state = false
							}
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
									time.sleep(80 * time.millisecond)
									// buf.temp_cursor.y = 0
									buf.temp_cursor.y = 0
									view.update_offset_for_temp(buf.temp_cursor.y)
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
								// view.cursor = buf.temp_cursor
								view.update_offset(view.cursor.y, buf.buffer)

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
									time.sleep(80 * time.millisecond)
									buf.temp_cursor.y = 0
									view.update_offset_for_temp(buf.temp_cursor.y)
								} else if buf.temp_fuzzy_type == .file {
									buf.temp_label = ''
									buf.temp_data.clear()
									buf.file_ch.close()
									buf.p_mode = buf.temp_mode
									buf.temp_fuzzy_type = .dir
									// reset and open fuzzy
									buf.open_fuzzy_find(buf.temp_path, .directory)
									time.sleep(80 * time.millisecond)
									buf.temp_cursor.y = 0
									view.update_offset_for_temp(buf.temp_cursor.y)
								}
							}
							.tab {
								if buf.temp_data.len > 0 {
									file := buf.temp_data[0].string()

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
										time.sleep(80 * time.millisecond)
										buf.temp_cursor.y = 0
										view.update_offset_for_temp(buf.temp_cursor.y)
									}
								}
							}
							.comma {
								if buf.temp_data.len > 0 {
									file := buf.temp_data[0].string()
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
									file := buf.temp_data[0].string()

									// buf.path = buf.temp_path
									buf.p_mode = buf.temp_mode
									buf.mode = .normal
									// buf.logical_cursor = buf.temp_cursor
									view.update_offset(view.cursor.y, buf.buffer)
									view.existing_cursors[app.active_buffer] = view.cursor
									view.existing_offsets[app.active_buffer] = view.row_offset
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
										buf.temp_list << path
										// if buf.temp_list.len == 0 {
										// 	buf.temp_list << path
										// }
									}
									file_list := buf.temp_list.clone()
									// tabsize := view.tabsize

									for i, paths in file_list {
										if i == 0 {
											app.add_new_buffer(
												name: os.file_name(paths)
												path: paths
												// tabsize: tabsize
												type:   .gap
												mode:   .normal
												p_mode: .default
											)
										} else {
											app.append_new_buffer(
												name: os.file_name(paths)
												path: paths
												// tabsize: tabsize
												type:   .gap
												mode:   .normal
												p_mode: .default
											)
										}
									}
									app.active_buffer = app.buffers.len - 1
									view.row_offset = if view.existing_offsets.keys().contains(app.active_buffer) {
										view.existing_offsets[app.active_buffer]
									} else {
										0
									}
									if view.existing_cursors.keys().contains(app.active_buffer) {
										view.cursor = view.existing_cursors[app.active_buffer]
									} else {
										view.cursor.x = 0
										view.cursor.y = 0
										view.cursor.flat_index = 0
										view.cursor.visual_x = 0
										view.cursor.desired_col = 0
									}
									view.fill_visible_lines(buf.buffer)
									// view.update_offset(app.buffers[app.active_buffer].logical_cursor.y,
									// 	buf.buffer)
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
								buf.prev_mode = buf.mode
								// buf.saved_cursor = buf.logical_cursor
								buf.mode = .command
								buf.cmd.command = ': '
								buf.menu_state = false
							}
							else {
								buf.temp_label += rune(int(key)).str()
								if buf.temp_cursor.y > buf.temp_data.len {
									buf.temp_cursor.y = 0
									view.update_offset(view.cursor.y, buf.buffer)
								}
							}
						}
					}
				}
			}
		}
	}
}
