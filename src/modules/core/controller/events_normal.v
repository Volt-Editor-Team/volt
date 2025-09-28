module controller

import fs
import os

pub fn handle_normal_mode_event(x voidptr, mod Modifier, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	// global normal mode
	if event == .key_down {
		match key {
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
				.space {
					buf.mode = .menu
				}
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
					line := buf.visual_col[buf.logical_cursor.y]

					// total wraps in the current line
					mut total_wraps := 0
					if line.len != 0 {
						total_wraps = line[line.len - 1] / app.viewport.width
					}

					// current wrap index
					cur_wrap := buf.visual_cursor.x / app.viewport.width

					if cur_wrap < total_wraps {
						buf.visual_cursor.x += app.viewport.width
						buf.logical_cursor.x = buf.logical_x(buf.logical_cursor.y, buf.visual_cursor.x)
					} else {
						buf.logical_cursor.move_down_buffer(buf.lines, buf.logical_x)
					}

					// update visual cursor to match logical cursor
					buf.update_visual_cursor(app.viewport.width)

					// update viewport offset
					buf.update_offset(app.viewport.visual_wraps, app.viewport.height,
						app.viewport.margin)
				}
				.k, .up {
					cur_wrap := buf.visual_cursor.x / app.viewport.width
					if cur_wrap == 0 {
						if buf.logical_cursor.y - 1 > 0 {
							line := buf.visual_col[buf.logical_cursor.y - 1]

							mut total_wraps := 0
							if line.len != 0 {
								total_wraps = line[line.len - 1] / app.viewport.width
							}
							if total_wraps > 0 {
								buf.logical_cursor.y--
								buf.visual_cursor.x += total_wraps * app.viewport.width
								buf.logical_cursor.x = buf.logical_x(buf.logical_cursor.y,
									buf.visual_cursor.x)
							} else {
								buf.logical_cursor.move_up_buffer(buf.logical_x)
							}
						} else {
							buf.logical_cursor.move_up_buffer(buf.logical_x)
						}
					} else {
						buf.visual_cursor.x -= app.viewport.width
						buf.logical_cursor.x = buf.logical_x(buf.logical_cursor.y, buf.visual_cursor.x)
					}

					buf.update_visual_cursor(app.viewport.width)
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
				.g {
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
						buf.visual_col = [][]int{len: buf.lines.len}
						buf.update_all_line_cache()

						buf.update_visual_cursor(app.viewport.width)
						buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
					}
				}
				.backspace {
					parent_dir, paths := fs.get_paths_from_parent_dir(buf.path)
					buf.path = parent_dir
					buf.lines = paths
					buf.visual_col = [][]int{len: buf.lines.len}
					buf.update_all_line_cache()

					buf.logical_cursor.x = 0
					buf.logical_cursor.y = 0
					buf.update_visual_cursor(app.viewport.width)
					buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
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
					file := buf.temp_data[buf.logical_cursor.y]

					buf.path = buf.temp_path
					buf.p_mode = buf.temp_mode
					buf.mode = .normal
					buf.logical_cursor = buf.temp_cursor
					buf.update_visual_cursor(app.viewport.width)
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
							buf.update_visual_cursor(app.viewport.width)
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
