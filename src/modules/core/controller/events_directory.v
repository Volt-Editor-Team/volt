module controller

import fs

pub fn handle_directory_mode_event(x voidptr, event EventType, key KeyCode) {
	mut app := get_app(x)
	mut buf := &app.buffers[app.active_buffer]
	if event == .key_down {
		match key {
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
