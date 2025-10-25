module controller

import fs
import os
import util

pub fn handle_normal_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	// global normal mode
	if event == .key_down {
		match key {
			.space {
				buf.mode = .menu
			}
			.g {
				buf.mode = .goto
			}
			.i {
				buf.mode = .insert
			}
			.colon {
				buf.saved_cursor = buf.logical_cursor
				buf.mode = .command
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
				.l, .right {
					prev_y := buf.logical_cursor.y
					buf.logical_cursor.move_right_buffer(buf.lines)
					// buf.update_visual_cursor(app.viewport.width)
					cur_line := buf.lines[buf.logical_cursor.y]
					visual_index := util.char_count_expanded_tabs(cur_line#[..
						buf.logical_cursor.x + 1], buf.tabsize)

					buf.logical_cursor.update_desired_col(visual_index, app.viewport.width)
					if buf.logical_cursor.y != prev_y {
						buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
							app.viewport.margin)
					}
				}
				.h, .left {
					prev_y := buf.logical_cursor.y
					buf.logical_cursor.move_left_buffer(buf.lines)
					// buf.update_visual_cursor(app.viewport.width)
					// buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
					cur_line := buf.lines[buf.logical_cursor.y]
					visual_index := util.char_count_expanded_tabs(cur_line#[..
						buf.logical_cursor.x + 1], buf.tabsize)
					buf.logical_cursor.update_desired_col(visual_index, app.viewport.width)
					if buf.logical_cursor.y != prev_y {
						buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
							app.viewport.margin)
					}
				}
				.j, .down {
					line := buf.lines[buf.logical_cursor.y]

					// total wraps in the current line
					mut total_wraps := 0
					if line.len != 0 {
						total_wraps = util.char_count_expanded_tabs(line, buf.tabsize) / app.viewport.width
					}

					// current wrap index
					cur_wrap := buf.logical_cursor.x / app.viewport.width

					if cur_wrap < total_wraps {
						buf.visual_cursor.x += app.viewport.width

						buf.logical_cursor.x = util.char_count_expanded_tabs(line[..
							buf.logical_cursor.x + app.viewport.width], buf.tabsize)
						// buf.logical_cursor.x = buf.logical_x(buf.logical_cursor.y, buf.visual_cursor.x)
					} else {
						buf.logical_cursor.move_down_buffer(buf.lines, buf.tabsize)
					}

					// update visual cursor to match logical cursor
					// buf.update_visual_cursor(app.viewport.width)

					// update viewport offset
					buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
						app.viewport.margin)
				}
				.k, .up {
					cur_wrap := buf.visual_cursor.x / app.viewport.width
					if cur_wrap == 0 {
						if buf.logical_cursor.y - 1 > 0 {
							line := buf.lines[buf.logical_cursor.y - 1]

							mut total_wraps := 0
							if line.runes().len != 0 {
								total_wraps = util.char_count_expanded_tabs(line, buf.tabsize) / app.viewport.width
							}
							if total_wraps > 0 {
								buf.logical_cursor.y--
								// buf.visual_cursor.x += total_wraps * app.viewport.width
								// buf.logical_cursor.x = buf.logical_x(buf.logical_cursor.y,
								// buf.visual_cursor.x)
								buf.logical_cursor.x = util.char_count_expanded_tabs(line[..total_wraps * app.viewport.width],
									buf.tabsize)
							} else {
								buf.logical_cursor.move_up_buffer(buf.lines, buf.tabsize)
							}
						} else {
							buf.logical_cursor.move_up_buffer(buf.lines, buf.tabsize)
						}
					} else {
						// buf.visual_cursor.x -= app.viewport.width
						// buf.logical_cursor.x = buf.logical_x(buf.logical_cursor.y, buf.visual_cursor.x)
						line := buf.lines[buf.logical_cursor.y]
						buf.logical_cursor.x = util.char_count_expanded_tabs(line[..buf.logical_cursor.x - app.viewport.width],
							buf.tabsize)
					}

					// buf.update_visual_cursor(app.viewport.width)
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
			match key {
				.enter {
					path := buf.lines[buf.logical_cursor.y]
					app.add_new_buffer(
						name:    os.file_name(path)
						path:    buf.path + path
						tabsize: buf.tabsize
						mode:    .normal
						p_mode:  .default
					)
				}
				.tab {
					path := buf.lines[buf.logical_cursor.y]

					if fs.is_dir(buf.path + path) {
						parent_dir, paths := fs.get_paths_from_dir(buf.path, path)
						buf.path = parent_dir
						buf.lines = paths

						buf.logical_cursor.x = 0
						buf.logical_cursor.y = 0
						// buf.visual_col = [][]int{len: buf.lines.len}
						// 	buf.update_all_line_cache()

						// 	buf.update_visual_cursor(app.viewport.width)
						// 	buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
					}
				}
				.backspace {
					parent_dir, paths := fs.get_paths_from_parent_dir(buf.path)
					buf.path = parent_dir
					buf.lines = paths
					// buf.visual_col = [][]int{len: buf.lines.len}
					// buf.update_all_line_cache()

					buf.logical_cursor.x = 0
					buf.logical_cursor.y = 0
					// buf.update_visual_cursor(app.viewport.width)
					// buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
				}
				else {}
			}
		}
		.fuzzy {
			match key {
				.j, .down {
					if buf.logical_cursor.y < buf.temp_data.len - 1 {
						buf.logical_cursor.y++
					}
				}
				.k, .up {
					if buf.logical_cursor.y > 0 {
						buf.logical_cursor.y--
					}
				}
				.enter {
					if buf.temp_data.len > 0 {
						file := buf.temp_data[buf.logical_cursor.y]

						buf.path = buf.temp_path
						buf.p_mode = buf.temp_mode
						buf.mode = .normal
						buf.logical_cursor = buf.temp_cursor
						// 	buf.update_visual_cursor(app.viewport.width)
						buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
							app.viewport.margin)

						// delete temp stuff
						buf.temp_label = ''
						buf.temp_data.clear()

						app.add_new_buffer(
							name:    os.file_name(file)
							path:    file
							tabsize: buf.tabsize
							mode:    .normal
							p_mode:  .default
						)
					}
				}
				else {}
			}
			match mod {
				.ctrl {
					match key {
						.q {
							// restore settings
							buf.path = buf.temp_path
							buf.p_mode = buf.temp_mode
							buf.mode = .normal
							buf.logical_cursor = buf.temp_cursor
							// 		buf.update_visual_cursor(app.viewport.width)
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
				else {}
			}
		}
		else {}
	}
}
