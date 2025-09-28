module core

import buffer { Buffer }
import util
import fs { get_working_dir_paths }

pub fn (mut app App) add_new_buffer(b Buffer) {
	new_buf := Buffer.new(
		label:   b.label
		name:    b.name
		path:    b.path
		lines:   b.lines
		tabsize: default_tabsize
		mode:    .normal
		p_mode:  b.p_mode
	)
	if app.buffers.len == 1 && app.buffers[app.active_buffer].path == 'Scratch' {
		app.buffers[0] = new_buf
	} else {
		app.buffers << new_buf
		app.change_active_buffer(app.buffers.len - 1)
	}
}

pub fn (mut app App) change_active_buffer(idx int) {
	app.active_buffer = idx
}

pub fn (mut app App) add_directory_buffer() {
	parent_dir, lines := get_working_dir_paths()
	app.add_new_buffer(
		name:   'DIRECTORY'
		path:   parent_dir
		lines:  lines
		p_mode: util.PersistantMode.directory
	)
}

pub fn (mut app App) add_stats_buffer() {
	lines := app.get_stats()
	app.add_new_buffer(
		name:  'DOCTOR'
		path:  'V DOCTOR OUTPUT'
		lines: lines
		mode:  .normal
	)
}

pub fn (mut app App) add_help_buffer() {
	help_path := $embed_file('./src/modules/docs/help.txt').to_string().split_into_lines()
	app.add_new_buffer(
		name:  'HELP'
		path:  'HELP DOCUMENTATION'
		lines: help_path
		mode:  .normal
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
