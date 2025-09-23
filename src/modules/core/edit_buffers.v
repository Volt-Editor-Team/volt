module core

import buffer { Buffer }
import util
import fs { get_working_dir_paths }
import os

pub fn (mut app App) add_new_buffer(b Buffer) {
	app.buffers << Buffer.new(
		name:    b.name
		path:    b.path
		lines:   b.lines
		tabsize: default_tabsize
		mode:    b.mode
	)
	app.change_active_buffer(app.buffers.len - 1)
}

pub fn (mut app App) change_active_buffer(idx int) {
	app.active_buffer = idx
}

pub fn (mut app App) add_directory_buffer() {
	parent_dir, lines := get_working_dir_paths()
	app.add_new_buffer(
		name:  'DIRECTORY'
		path:  parent_dir
		lines: lines
		mode:  util.Mode.directory
	)
}

pub fn (mut app App) add_stats_buffer() {
	lines := app.get_stats()
	app.add_new_buffer(
		name:  'DOCTOR'
		path:  'V DOCTOR OUTPUT'
		lines: lines
		mode:  util.Mode.normal
	)
}

pub fn (mut app App) close_buffer() {
	app.buffers.delete(app.active_buffer)

	if app.active_buffer > 0 {
		app.active_buffer--
	}
	if app.buffers.len == 0 {
		app.add_new_buffer(mode: util.Mode.normal)
	}
}

pub fn (mut app App) swap_to_temp_fuzzy_buffer() {
	mut path := app.buffers[app.active_buffer].path
	if !fs.is_dir(path) {
		path = os.dir(path)
	}
	app.swap_map[app.active_buffer] = app.buffers[app.active_buffer]

	mut cur_buf := &app.buffers[app.active_buffer]

	// cur_buf.label = 'FUZZY'
	cur_buf.name = ''
	cur_buf.path = path
	cur_buf.p_mode = util.Mode.fuzzy
	cur_buf.mode = cur_buf.p_mode
	cur_buf.lines = ['fuzzy']
	cur_buf.logical_cursor.x = 0
	cur_buf.logical_cursor.y = 0
	cur_buf.visual_cursor.x = 0
	cur_buf.visual_cursor.y = 0
	cur_buf.saved_cursor = cur_buf.logical_cursor
	cur_buf.row_offset = 0
	cur_buf.update_all_line_cache()
}
