module core

import buffer { Buffer }
import fs { get_working_dir_paths }

pub fn (mut app App) add_new_buffer(b Buffer) {
	app.buffers << Buffer.new(
		path:                b.path
		lines:               b.lines
		tabsize:             default_tabsize
		is_directory_buffer: b.is_directory_buffer
	)
	app.change_active_buffer(app.buffers.len - 1)
}

pub fn (mut app App) change_active_buffer(idx int) {
	app.active_buffer = idx
}

pub fn (mut app App) add_directory_buffer() {
	lines := get_working_dir_paths()
	app.add_new_buffer(lines: lines, is_directory_buffer: true)
}

pub fn (mut app App) close_buffer() {
	app.buffers.delete(app.active_buffer)

	if app.active_buffer > 0 {
		app.active_buffer--
	}
	if app.buffers.len == 0 {
		app.add_new_buffer(is_directory_buffer: false)
	}
}
