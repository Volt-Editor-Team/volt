module controller

import fs

pub fn handle_normal_mode_event(x voidptr, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	if event == .key_down {
		match key {
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
				if wrap_points.len > 1 && buf.logical_cursor.x < wrap_points[wrap_points.len - 1] {
					new_width := buf.logical_cursor.x + app.viewport.width
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
						buf.update_all_line_cache()

						buf.update_visual_cursor(app.viewport.width)
						buf.logical_cursor.update_desired_col(buf.visual_cursor.x, app.viewport.width)
					}
				}
			}
			.backspace {
				if buf.is_directory_buffer {
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
}
